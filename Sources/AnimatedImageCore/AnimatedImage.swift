public import QuartzCore
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class AnimatedImage: Sendable {
    private let imageSource: any AnimatedImageSource
    private let configuration: AnimatedImage.Configuration
    private let imageProcessor: ImageProcessor
    private var state: AnimatedImageState

    public init(
        imageSource: any AnimatedImageSource,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        self.imageSource = imageSource
        self.configuration = configuration
        let cache = Cache<Int, CGImage>(name: imageSource.name)
        self.imageProcessor = ImageProcessor(configuration: configuration, cache: cache)
        self.state = AnimatedImageState(cache: cache)
    }

    var task: Task<Void, Never>? = nil
    var currentFrameIndex: Int? = nil

    public var contentsFilter: CALayerContentsFilter {
        configuration.contentsFilter
    }

    public func update(
        for renderSize: CGSize,
        scale: CGFloat
    ) {
        cancelCurrentTask()
        startImageProcessingTask(
            renderSize: renderSize,
            scale: scale
        )
    }

    public func cancelCurrentTask() {
        task?.cancel()
    }

    func startImageProcessingTask(
        renderSize: CGSize,
        scale: CGFloat
    ) {
        task = Task.detached(priority: configuration.taskPriority) { [weak self] in
            await withTaskCancellationHandler(
                operation: {
                    await self?
                        .processAnimatedImage(
                            renderSize: renderSize,
                            scale: scale
                        )
                },
                onCancel: {
                    //self?.state.removeAllCachedImages()
                }
            )
        }
    }

    @concurrent
    func processAnimatedImage(
        renderSize: CGSize,
        scale: CGFloat
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
    
    public func contents(at index: Int) -> CGImage? {
        let image = self.image(at: index)
        if image != nil {
            currentFrameIndex = index
        }
        return image
    }

    public func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> CGImage? {
        let index = self.index(for: targetTimestamp)
        guard let index, currentFrameIndex != index else { return nil }
        return contents(at: index)
    }
}
