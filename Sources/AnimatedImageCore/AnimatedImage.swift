public import QuartzCore
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class AnimatedImage: Identifiable, Sendable {
    public var id: String { imageSource.name }
    private let imageSource: any AnimatedImageSource
    private let configuration: AnimatedImage.Configuration
    private let imageProcessor: ImageProcessor
    private var state: AnimatedImageState?

    public init(
        imageSource: any AnimatedImageSource,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        self.imageSource = imageSource
        self.configuration = configuration
        self.imageProcessor = ImageProcessor(configuration: configuration)
    }
    
    @concurrent
    public func prepareForDisplay(
        for size: CGSize,
        scale: CGFloat
    ) async -> AnimatedImage {
        // TODO: if self is prepared and much size and scale, return self.
        let processingResult = await imageProcessor.processAnimatedImage(
            renderSize: Size(size),
            scale: scale,
            imageSource: imageSource
        )
        guard let processingResult else {
            return self
        }
        var animatedImage = await AnimatedImage(
            imageSource: imageSource,
            withConfiguration: configuration
        )
        await animatedImage.setState(processingResult)
        return animatedImage
    }
    
    private func setState(_ result: ImageProcessor.ProcessingResult) {
        var newState = AnimatedImageState(
            name: imageSource.name,
            indices: result.frameState.indices,
            delayTime: result.frameState.delayTime
        )
        newState.insertImages(result.images)
        state = newState
    }

    public func image(at index: Int) -> CGImage? {
        state?.image(at: index)
    }

    public func index(for targetTimestamp: TimeInterval) -> Int? {
        state?.frameIndex(for: targetTimestamp)
    }
}
