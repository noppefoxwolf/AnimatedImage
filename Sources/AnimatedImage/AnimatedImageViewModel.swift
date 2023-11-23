import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public struct AnimatedImageViewConfiguration: Sendable {
    public static var `default`: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: 1 * 1024 * 1024 * 1, // 1MB
            maxSize: CGSize(width: 128, height: 128),
            maxLevelOfIntegrity: 0.8,
            taskPriority: .medium
        )
    }
    
    public var maxByteCount: Int64
    public var maxSize: CGSize
    public var maxLevelOfIntegrity: Double
    public var taskPriority: TaskPriority
}

@MainActor
internal final class AnimatedImageViewModel: Sendable {
    let cache: Cache<Int, UIImage>
    let maxByteCount: Int64
    let maxSize: CGSize
    let maxLevelOfIntegrity: Double
    let taskPriority: TaskPriority
    
    init(name: String, configuration: AnimatedImageViewConfiguration) {
        self.cache = Cache(name: name)
        self.maxByteCount = configuration.maxByteCount
        self.maxSize = configuration.maxSize
        self.maxLevelOfIntegrity = configuration.maxLevelOfIntegrity
        self.taskPriority = configuration.taskPriority
    }
    
    var indices: [Int] = []
    
    var delayTime: Double = 0.1
    
    var task: Task<Void, Never>? = nil
    
    func update(for renderSize: CGSize, image: any AnimatedImage) {
        // TODO: 既にキャッシュ済み、生成中なら無視する
        task?.cancel()
        task = Task.detached(priority: taskPriority) { [image, cache, maxSize, maxByteCount, maxLevelOfIntegrity] in
            await withTaskCancellationHandler { [image, maxSize, maxByteCount, maxLevelOfIntegrity] in
                guard !CGRect(origin: .zero, size: renderSize).isEmpty else { return }
                let imageCount = autoreleasepool(invoking: { image.makeImageCount() })
                
                let newSize = min(maxSize, renderSize)
                let imageByteCount = Int(newSize.width) * Int(newSize.height) * 4
                let memoryPressure = Double(imageByteCount * imageCount) / Double(maxByteCount)
                let levelOfIntegrity = min(1.0 / memoryPressure, maxLevelOfIntegrity)
                
                let delayTimes = (0..<imageCount).map({ index in autoreleasepool(invoking: { image.makeDelayTime(at: index) }) })
                let (indices, delayTime) = self.decimateFrames(delays: delayTimes, levelOfIntegrity: levelOfIntegrity)
                
                await MainActor.run {
                    self.indices = indices
                    self.delayTime = delayTime
                }
                
                await withTaskGroup(of: Void.self) { taskGroup in
                    for i in Set(indices) {
                        taskGroup.addTask { [i] in
                            guard !Task.isCancelled else { return }
                            let image = autoreleasepool(invoking: { image.makeImage(at: i) })
                            let uiImage = image.map(UIImage.init(cgImage:))
                            
                            guard !Task.isCancelled else { return }
                            let decodedImage = await uiImage?.decoded(for: newSize)
                            
                            guard !Task.isCancelled else { return }
                            if let decodedImage {
                                cache.insert(decodedImage, forKey: i)
                            } else {
                                cache.removeValue(forKey: i)
                            }
                        }
                    }
                }
            } onCancel: { [cache] in
                cache.removeAllObjects()
            }
        }
    }
    
    nonisolated func makeImage(at index: Int) -> UIImage? {
        cache.value(forKey: index)
    }
    
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
    
    /// Based on https://github.com/kirualex/SwiftyGif
    /// See also UIImage+SwiftyGif.swift
    nonisolated private func decimateFrames(
        delays: [Double],
        levelOfIntegrity: Double
    ) -> (displayIndices: [Int], delay: Double) {
        // 保証する表示フレームの割合
        let levelOfIntegrity = max(0.0, min(1.0, levelOfIntegrity))
        // 各フレームが表示されるはずのtimestamp
        let timestamps = delays.runningSum.map({ $0 })
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
            let uniqueVsyncIndices = Set(vsyncIndices).map({ $0 })
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

