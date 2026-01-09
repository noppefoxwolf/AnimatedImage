public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var imageSource: (any AnimatedImageSource)? = nil {
        didSet {
            guard let imageSource else { return }
            provider = AnimatedImageProvider(
                name: imageSource.name,
                configuration: configuration
            )
        }
    }

    public var configuration: AnimatedImageProviderConfiguration = .default {
        didSet {
            if let imageSource {
                provider = AnimatedImageProvider(
                    name: imageSource.name,
                    configuration: configuration
                )
            }
            layer.magnificationFilter = configuration.contentsFilter
        }
    }

    private var provider: AnimatedImageProvider? = nil {
        didSet {
            contents = nil

            if let imageSource {
                provider?.update(
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
            provider?.cancelCurrentTask()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        if let imageSource {
            provider?.update(
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
        if let image = provider?.contentsForTimestamp(targetTimestamp) {
            contents = image
        }
    }
}
