import UIKit
import os

fileprivate let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

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
        cancelCurrentTask()
        startImageProcessingTask(renderSize: renderSize, image: image)
    }
    
    private func cancelCurrentTask() {
        task?.cancel()
    }
    
    private func startImageProcessingTask(renderSize: CGSize, image: any AnimatedImage) {
        task = Task.detached(priority: configuration.taskPriority) { [image, cache] in
            await withTaskCancellationHandler {
                await self.processAnimatedImage(renderSize: renderSize, image: image)
            } onCancel: { [cache] in
                cache.removeAllObjects()
            }
        }
    }
    
    private func processAnimatedImage(renderSize: CGSize, image: any AnimatedImage) async {
        guard validateRenderSize(renderSize) else { return }
        guard !Task.isCancelled else { return }
        
        let imageCount = autoreleasepool { image.makeImageCount() }
        guard !Task.isCancelled else { return }
        
        let optimizedSize = calculateOptimizedSize(renderSize: renderSize)
        let frameConfiguration = calculateFrameConfiguration(
            imageSize: optimizedSize,
            imageCount: imageCount,
            image: image
        )
        
        await updateFrameIndices(frameConfiguration)
        await generateFrameImages(frameConfiguration, image: image, cache: cache)
    }
    
    private func validateRenderSize(_ renderSize: CGSize) -> Bool {
        !CGRect(origin: .zero, size: renderSize).isEmpty
    }
    
    private func calculateOptimizedSize(renderSize: CGSize) -> CGSize {
        min(configuration.maxSize, renderSize)
    }
    
    private struct FrameConfiguration {
        let optimizedSize: CGSize
        let indices: [Int]
        let delayTime: Double
        let interpolationQuality: CGInterpolationQuality
    }
    
    private func calculateFrameConfiguration(
        imageSize: CGSize,
        imageCount: Int,
        image: any AnimatedImage
    ) -> FrameConfiguration {
        let imageByteCount = Int(imageSize.width) * Int(imageSize.height) * 4
        let memoryPressure = Double(imageByteCount * imageCount) / Double(configuration.maxByteCount)
        let levelOfIntegrity = min(1.0 / memoryPressure, configuration.maxLevelOfIntegrity)
        
        let delayTimes = (0..<imageCount).map { index in
            autoreleasepool { image.makeDelayTime(at: index) }
        }
        
        let decimator = FrameDecimator()
        let decimationResult = decimator.decimateFrames(
            delays: delayTimes,
            levelOfIntegrity: levelOfIntegrity
        )
        
        return FrameConfiguration(
            optimizedSize: imageSize,
            indices: decimationResult.displayIndices,
            delayTime: decimationResult.delayTime,
            interpolationQuality: configuration.interpolationQuality
        )
    }
    
    private func updateFrameIndices(_ frameConfiguration: FrameConfiguration) async {
        await MainActor.run {
            self.indices = frameConfiguration.indices
            self.delayTime = frameConfiguration.delayTime
        }
    }
    
    private func generateFrameImages(
        _ frameConfiguration: FrameConfiguration,
        image: any AnimatedImage,
        cache: Cache<CacheKey, UIImage>
    ) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            for index in Set(frameConfiguration.indices) {
                taskGroup.addTask {
                    await self.makeAndCacheImage(
                        image: image,
                        cache: cache,
                        size: frameConfiguration.optimizedSize,
                        index: index,
                        interpolationQuality: frameConfiguration.interpolationQuality
                    )
                }
            }
        }
    }
    
    @Sendable private func makeAndCacheImage(
        image: any AnimatedImage,
        cache: Cache<CacheKey, UIImage>,
        size: CGSize,
        index: Int,
        interpolationQuality: CGInterpolationQuality
    ) async {
        let cgImage = autoreleasepool { image.makeImage(at: index) }
        let uiImage = cgImage.map(UIImage.init(cgImage:))
        
        guard !Task.isCancelled else { return }
        let decodedImage = await uiImage?.decoded(for: size, interpolationQuality: interpolationQuality)
        
        guard !Task.isCancelled else { return }
        if let decodedImage {
            cache.insert(decodedImage, forKey: .index(index))
        } else {
            cache.removeValue(forKey: .index(index))
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

