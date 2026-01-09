public import QuartzCore
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class AnimatedImage: Sendable {
    private let configuration: AnimatedImageProviderConfiguration
    private let imageProcessor: ImageProcessor
    private var state: AnimatedImageState

    public init(name: String, configuration: AnimatedImageProviderConfiguration) {
        self.configuration = configuration
        let cache = Cache<Int, CGImage>(name: name)
        self.imageProcessor = ImageProcessor(configuration: configuration, cache: cache)
        self.state = AnimatedImageState(cache: cache)
    }

    var task: Task<Void, Never>? = nil
    var currentFrameIndex: Int? = nil

    public func update(
        for renderSize: CGSize,
        scale: CGFloat,
        imageSource: any AnimatedImageSource
    ) {
        cancelCurrentTask()
        startImageProcessingTask(
            renderSize: renderSize,
            scale: scale,
            imageSource: imageSource
        )
    }

    public func cancelCurrentTask() {
        task?.cancel()
    }

    func startImageProcessingTask(
        renderSize: CGSize,
        scale: CGFloat,
        imageSource: any AnimatedImageSource
    ) {
        task = Task.detached(priority: configuration.taskPriority) { [weak self] in
            await withTaskCancellationHandler(
                operation: {
                    await self?
                        .processAnimatedImage(
                            renderSize: renderSize,
                            scale: scale,
                            imageSource: imageSource
                        )
                },
                onCancel: {
                    self?.state.removeAllCachedImages()
                }
            )
        }
    }

    @concurrent
    func processAnimatedImage(
        renderSize: CGSize,
        scale: CGFloat,
        imageSource: any AnimatedImageSource
    ) async {
        let frameState = await imageProcessor.processAnimatedImage(
            renderSize: Size(renderSize),
            scale: scale,
            imageSource: imageSource
        )
        guard let frameState else { return }

        await updateFrameState(with: frameState)
    }

    func updateFrameState(with frameState: AnimatedImageState.FrameState) {
        state.update(with: frameState)
    }

    func image(at index: Int) -> CGImage? {
        state.image(at: index)
    }

    func index(for targetTimestamp: TimeInterval) -> Int? {
        state.frameIndex(for: targetTimestamp)
    }

    public func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> CGImage? {
        let index = self.index(for: targetTimestamp)
        guard let index, currentFrameIndex != index else { return nil }

        let image = self.image(at: index)
        if image != nil {
            currentFrameIndex = index
        }
        return image
    }
}
