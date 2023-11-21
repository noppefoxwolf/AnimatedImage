import UIKit
import os
import Algorithms

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

internal final class GifImageViewCache {
    let cache = Cache<Int, UIImage>(name: UUID().uuidString)
    let maxByteCount: Int64 = 1 * 1024 * 1024 * 1 // 1MB
    let maxSize: CGSize = CGSize(width: 128, height: 128)
    let maxLevelOfIntegrity: Double = 0.8
    
    @MainActor
    var indices: [Int] = []
    
    @MainActor
    var delayTime: Double = 0.1
    
    var task: Task<Void, Never>? = nil
    
    nonisolated func update(for renderSize: CGSize, image: GifImage) {
        // TODO: 既にキャッシュ済み、生成中なら無視する
        task?.cancel()
        task = Task.detached { [image, cache, maxSize, maxByteCount, maxLevelOfIntegrity] in
            await withTaskCancellationHandler { [image, maxSize, maxByteCount, maxLevelOfIntegrity] in
                guard !CGRect(origin: .zero, size: renderSize).isEmpty else { return }
                let imageCount = image.imageCount
                
                let newSize = min(maxSize, renderSize)
                let imageByteCount = Int(newSize.width) * Int(newSize.height) * 4
                let memoryPressure = Double(imageByteCount * imageCount) / Double(maxByteCount)
                let levelOfIntegrity = min(1.0 / memoryPressure, maxLevelOfIntegrity)
                
                let delayTimes = (0..<imageCount).map({ image.delayTime(at: $0) })
                let (indices, delayTime) = self.decimateFrames(delays: delayTimes, levelOfIntegrity: levelOfIntegrity)
                await MainActor.run {
                    self.indices = indices
                    self.delayTime = delayTime
                }
                for i in indices {
                    let cgImage = image.image(at: i)!
                    let image = UIImage(cgImage: cgImage)
                    let decodedImage = await image.decoded(for: newSize)!
                    cache.insert(decodedImage, forKey: i)
                }
            } onCancel: { [cache] in
                cache.removeAllObjects()
            }
        }
    }
    
    @MainActor
    func image(at index: Int) -> UIImage? {
        cache.value(forKey: index)
    }
    
    @MainActor
    func index(for targetTimestamp: TimeInterval) -> Int? {
        guard !indices.isEmpty else { return nil }
        guard delayTime != 0 else { return nil }
        let duration = delayTime * Double(indices.count)
        let timestamp = targetTimestamp.truncatingRemainder(
            dividingBy: duration
        )
        let factor = timestamp / duration
        let index = Int(Double(indices.count) * factor)
        return indices[index]
    }
    
    /// Based on https://github.com/kirualex/SwiftyGif/blob/7b6f8039b288ec5840501d504e1e3fca486916ec/SwiftyGif/UIImage%2BSwiftyGif.swift#L208C62-L208C78
    private func decimateFrames(
        delays: [Double],
        levelOfIntegrity: Double
    ) -> (displayIndices: [Int], delay: Double) {
        // 保証する表示フレームの割合
        let levelOfIntegrity = max(0.0, min(1.0, levelOfIntegrity))
        // 各フレームが表示されるはずのtimestamp
        let timestamps = delays.reductions(+)
        // １フレームあたりの時間の候補
        let vsyncInterval: [Double] = [
            1.0 / 1.0,
            1.0 / 2.0,
            1.0 / 3.0,
            1.0 / 4.0,
            1.0 / 5.0,
            1.0 / 6.0,
            1.0 / 10.0,
            1.0 / 12.0,
            1.0 / 15.0,
            1.0 / 20.0,
            1.0 / 30.0,
            1.0 / 60.0,
        ]
        
        var resultDelayTime: Double = 0.1
        var displayIndices: [Int] = (0..<delays.count).map({ $0 })
        
        // 2枚未満は無条件で出す
        if delays.count <= 2 {
            return (displayIndices, resultDelayTime)
        }
        
        for delayTime in vsyncInterval {
            // 候補のフレーム時間で描画された時のvsyncの位置
            let vsyncIndices = timestamps.map { Int($0 / delayTime) }
            let uniqueVsyncIndices = vsyncIndices.uniqued().map({ $0 })
            // 表示に必要なフレーム数
            let needsDisplayFrameCount = Int(
                Double(vsyncIndices.count) * levelOfIntegrity
            )
            let displayFrameCount = uniqueVsyncIndices.count
            let isEnoughFrameCount = displayFrameCount >= needsDisplayFrameCount
            
            if isEnoughFrameCount {
                let imageCount = uniqueVsyncIndices.count
                
                var oldIndex = 0
                var newIndex = 0
                displayIndices = []
                
                while newIndex <= imageCount && oldIndex < vsyncIndices.count {
                    if newIndex <= vsyncIndices[oldIndex] {
                        displayIndices.append(oldIndex)
                        newIndex += 1
                    } else {
                        oldIndex += 1
                    }
                }
                resultDelayTime = delayTime
                break
            }
        }
        
        return (displayIndices, resultDelayTime)
    }
}

