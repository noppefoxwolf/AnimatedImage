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
    
    private let cache: Cache<CacheKey, CGImage>
    private let configuration: AnimatedImageViewConfiguration
    private let imageProcessor: ImageProcessor
    private let timingCalculator: AnimationTimingCalculator
    
    init(name: String, configuration: AnimatedImageViewConfiguration) {
        self.cache = Cache(name: name)
        self.configuration = configuration
        self.imageProcessor = ImageProcessor(configuration: configuration)
        self.timingCalculator = AnimationTimingCalculator()
    }
    
    var indices: [Int] = []
    var delayTime: Double = 0.1
    var task: Task<Void, Never>? = nil
    var currentIndex: Int? = nil
    
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
    
    nonisolated private func processAnimatedImage(renderSize: CGSize, image: any AnimatedImage) async {
        guard let processingResult = await imageProcessor.processAnimatedImage(
            renderSize: renderSize,
            image: image
        ) else { return }
        
        await updateFrameIndices(processingResult.frameConfiguration)
        await cacheGeneratedImages(processingResult.generatedImages)
    }
    
    
    @MainActor
    private func updateFrameIndices(_ frameConfiguration: ImageProcessor.FrameConfiguration) {
        self.indices = frameConfiguration.indices
        self.delayTime = frameConfiguration.delayTime
    }
    
    nonisolated private func cacheGeneratedImages(_ generatedImages: [Int: CGImage]) async {
        for (index, image) in generatedImages {
            guard !Task.isCancelled else { return }
            cache.insert(image, forKey: .index(index))
        }
    }
    
    nonisolated func image(at index: Int) -> CGImage? {
        cache.value(forKey: .index(index))
    }
    
    func index(for targetTimestamp: TimeInterval) -> Int? {
        timingCalculator.calculateFrameIndex(
            for: targetTimestamp,
            indices: indices,
            delayTime: delayTime
        )
    }
    
    func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> CGImage? {
        let index = self.index(for: targetTimestamp)
        guard let index, currentIndex != index else { return nil }
        
        let image = self.image(at: index)
        if image != nil {
            currentIndex = index
        }
        return image
    }
    
}

