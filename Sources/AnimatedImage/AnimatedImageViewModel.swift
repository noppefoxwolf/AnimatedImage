public import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public struct AnimatedImageViewConfiguration: Sendable {
    public static var unlimited: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: .max,
            maxSize: CGSize(width: Double.infinity, height: Double.infinity),
            maxLevelOfIntegrity: 1,
            interpolationQuality: .high,
            contentsFilter: .trilinear,
            taskPriority: .userInitiated
        )
    }
    
    public static var `default`: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: 1 * 1024 * 1024, // 1MB
            maxSize: CGSize(width: 128, height: 128),
            maxLevelOfIntegrity: 0.8,
            interpolationQuality: .default,
            contentsFilter: .linear,
            taskPriority: .medium
        )
    }
    
    public static var performance: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: 1 * 1024 * 1024 / 50, // 20KB
            maxSize: CGSize(width: 32, height: 32),
            maxLevelOfIntegrity: 0.25,
            interpolationQuality: .none,
            contentsFilter: .nearest,
            taskPriority: .low
        )
    }
    
    public var maxByteCount: Int64
    public var maxSize: CGSize
    public var maxLevelOfIntegrity: Double
    public var interpolationQuality: CGInterpolationQuality
    public var contentsFilter: CALayerContentsFilter
    public var taskPriority: TaskPriority
}

@MainActor
internal final class AnimatedImageViewModel: Sendable {
    enum CacheKey: Hashable {
        case index(Int)
    }
    let cache: Cache<CacheKey, UIImage>
    let configuration: AnimatedImageViewConfiguration
    
    init(name: String, configuration: AnimatedImageViewConfiguration) {
        self.cache = Cache(name: name)
        self.configuration = configuration
    }
    
    var indices: [Int] = []
    
    var delayTime: Double = 0.1
    
    var task: Task<Void, Never>? = nil
    
    func update(for renderSize: CGSize, image: any AnimatedImage) {
        // TODO: 既にキャッシュ済み、生成中なら無視する
        task?.cancel()
        task = Task.detached(priority: configuration.taskPriority) { [image, cache, configuration] in
            await withTaskCancellationHandler { [image, configuration] in
                @Sendable func makeAndCacheImage(
                    size: CGSize,
                    index: Int,
                    key: CacheKey,
                    interpolationQuality: CGInterpolationQuality
                ) async {
                    let image = autoreleasepool(invoking: { image.makeImage(at: index) })
                    let uiImage = image.map(UIImage.init(cgImage:))
                    
                    guard !Task.isCancelled else { return }
                    let decodedImage = await uiImage?.decoded(for: size, interpolationQuality: interpolationQuality)
                    
                    guard !Task.isCancelled else { return }
                    if let decodedImage {
                        cache.insert(decodedImage, forKey: key)
                    } else {
                        cache.removeValue(forKey: key)
                    }
                }
                
                guard !CGRect(origin: .zero, size: renderSize).isEmpty else { return }
                guard !Task.isCancelled else { return }
                let imageCount = autoreleasepool(invoking: { image.makeImageCount() })
                
                guard !Task.isCancelled else { return }
                let newSize = min(configuration.maxSize, renderSize)
                let imageByteCount = Int(newSize.width) * Int(newSize.height) * 4
                let memoryPressure = Double(imageByteCount * imageCount) / Double(configuration.maxByteCount)
                let levelOfIntegrity = min(1.0 / memoryPressure, configuration.maxLevelOfIntegrity)
                let delayTimes = (0..<imageCount).map({ index in autoreleasepool(invoking: { image.makeDelayTime(at: index) }) })
                let decimator = FrameDecimator()
                let decimationResult = decimator.decimateFrames(delays: delayTimes, levelOfIntegrity: levelOfIntegrity)
                let (indices, delayTime) = (decimationResult.displayIndices, decimationResult.delayTime)
                
                await MainActor.run {
                    self.indices = indices
                    self.delayTime = delayTime
                }
                
                await withTaskGroup(of: Void.self) { [configuration] taskGroup in
                    for i in Set(indices) {
                        taskGroup.addTask { [i] in
                            await makeAndCacheImage(
                                size: newSize,
                                index: i,
                                key: .index(i),
                                interpolationQuality: configuration.interpolationQuality
                            )
                        }
                    }
                }
            } onCancel: { [cache] in
                cache.removeAllObjects()
            }
        }
    }
    
    nonisolated func makeImage(at index: Int) -> UIImage? {
        cache.value(forKey: .index(index))
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
    
}

