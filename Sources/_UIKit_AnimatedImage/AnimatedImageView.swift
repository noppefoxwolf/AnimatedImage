public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var imageSource: (any AnimatedImageSource)? = nil {
        didSet {
            guard let imageSource else { return }
            animatedImage = AnimatedImage(
                name: imageSource.name,
                configuration: configuration
            )
        }
    }

    public var configuration: AnimatedImageProviderConfiguration = .default {
        didSet {
            if let imageSource {
                animatedImage = AnimatedImage(
                    name: imageSource.name,
                    configuration: configuration
                )
            }
            layer.magnificationFilter = configuration.contentsFilter
        }
    }

    private var animatedImage: AnimatedImage? = nil {
        didSet {
            contents = nil

            if let imageSource {
                animatedImage?.update(
                    for: bounds.size,
                    scale: traitCollection.displayScale,
                    imageSource: imageSource
                )
            }

            setNeedsDisplay()
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            animatedImage?.cancelCurrentTask()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if let imageSource {
            animatedImage?.update(
                for: bounds.size,
                scale: traitCollection.displayScale,
                imageSource: imageSource
            )
        }
    }

    open override func willUpdateContents(
        _ contents: inout CGImage?,
        for targetTimestamp: TimeInterval
    ) {
        if let image = animatedImage?.contentsForTimestamp(targetTimestamp) {
            contents = image
        }
    }
}
