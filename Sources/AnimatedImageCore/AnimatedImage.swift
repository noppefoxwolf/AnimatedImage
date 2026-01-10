public import QuartzCore
import os

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier! + ".logger",
    category: #file
)

public final class AnimatedImage: Identifiable, Sendable {
    public var id: String { imageSource.name }
    private let imageSource: any AnimatedImageSource
    public let configuration: AnimatedImage.Configuration
    private let state: AnimatedImageState?

    init(
        imageSource: any AnimatedImageSource,
        withConfiguration configuration: AnimatedImage.Configuration,
        state: AnimatedImageState?
    ) {
        self.imageSource = imageSource
        self.configuration = configuration
        self.state = state
    }

    @concurrent
    public func prepareForDisplay(
        for size: CGSize,
        scale: CGFloat
    ) async -> AnimatedImage {
        let imageProcessor = ImageProcessor()
        let processingResult = await imageProcessor.processAnimatedImage(
            renderSize: Size(size),
            scale: scale,
            imageSource: imageSource,
            interpolationQuality: configuration.interpolationQuality,
            maxSize: configuration.maxSize,
            maxMemoryUsage: configuration.maxMemoryUsage.converted(to: .bytes).value,
            maxLevelOfIntegrity: configuration.maxLevelOfIntegrity
        )
        guard let processingResult else {
            return self
        }
        let state = await AnimatedImageState(
            name: imageSource.name,
            size: processingResult.size,
            indices: processingResult.indices,
            delayTime: processingResult.delayTime,
            images: processingResult.images,
            totalCostLimit: Int(configuration.maxMemoryUsage.converted(to: .bytes).value)
        )
        let animatedImage = await AnimatedImage(
            imageSource: imageSource,
            withConfiguration: configuration,
            state: state
        )
        return animatedImage
    }

    public static func estimatedMemoryCost(
        size: CGSize,
        scale: CGFloat,
    ) -> Int {
        let pixelSize = size.applying(CGAffineTransform(scaleX: scale, y: scale))
        return Int(pixelSize.width) * 4 * Int(pixelSize.height)
    }

    public func image(at index: Int) -> CGImage? {
        state?.image(at: index)
    }

    public func index(for targetTimestamp: TimeInterval) -> Int? {
        state?.frameIndex(for: targetTimestamp)
    }
}

extension AnimatedImage {
    public convenience init(
        imageSource: any AnimatedImageSource,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        self.init(
            imageSource: imageSource,
            withConfiguration: configuration,
            state: nil
        )
    }
}
