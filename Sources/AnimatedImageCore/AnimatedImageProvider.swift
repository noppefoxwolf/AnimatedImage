import QuartzCore
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

@MainActor
public final class AnimatedImageProvider: Sendable {
    private let cache: Cache<Int, CGImage>
    private let configuration: AnimatedImageProviderConfiguration
    private let imageProcessor: ImageProcessor
    private let timingCalculator: AnimationTimingCalculator

    public init(name: String, configuration: AnimatedImageProviderConfiguration) {
        self.cache = Cache(name: name)
        self.configuration = configuration
        self.imageProcessor = ImageProcessor(configuration: configuration, cache: cache)
        self.timingCalculator = AnimationTimingCalculator()
    }

    var indices: [Int] = []
    var delayTime: Double = 0.1
    var task: Task<Void, Never>? = nil
    var currentIndex: Int? = nil

    public func update(for renderSize: CGSize, scale: CGFloat, image: any AnimatedImage) {
        cancelCurrentTask()
        startImageProcessingTask(renderSize: renderSize, scale: scale, image: image)
    }

    public func cancelCurrentTask() {
        task?.cancel()
    }

    func startImageProcessingTask(renderSize: CGSize, scale: CGFloat, image: any AnimatedImage) {
        task = Task.detached(priority: configuration.taskPriority) { [image, cache] in
            await withTaskCancellationHandler {
                await self.processAnimatedImage(renderSize: renderSize, scale: scale, image: image)
            } onCancel: { [cache] in
                cache.removeAllObjects()
            }
        }
    }

    nonisolated func processAnimatedImage(
        renderSize: CGSize,
        scale: CGFloat,
        image: any AnimatedImage
    ) async {
        let processingResult = await imageProcessor.processAnimatedImage(
            renderSize: Size(renderSize),
            scale: scale,
            image: image
        )
        guard let processingResult else { return }

        await updateFrameIndices(processingResult.frameConfiguration)
    }

    func updateFrameIndices(_ frameConfiguration: ImageProcessor.FrameConfiguration) {
        self.indices = frameConfiguration.indices
        self.delayTime = frameConfiguration.delayTime
    }

    nonisolated func image(at index: Int) -> CGImage? {
        cache.value(forKey: index)
    }

    func index(for targetTimestamp: TimeInterval) -> Int? {
        timingCalculator.frameIndex(
            for: targetTimestamp,
            indices: indices,
            delayTime: delayTime
        )
    }

    public func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> CGImage? {
        let index = self.index(for: targetTimestamp)
        guard let index, currentIndex != index else { return nil }

        let image = self.image(at: index)
        if image != nil {
            currentIndex = index
        }
        return image
    }
}
