import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var image: (any AnimatedImage)? = nil {
        didSet {
            if let image {
                provider = AnimatedImageProvider(name: image.name, configuration: configuration)
            }
        }
    }

    public var configuration: AnimatedImageProviderConfiguration = .default {
        didSet {
            if let image {
                provider = AnimatedImageProvider(name: image.name, configuration: configuration)
            }
            layer.magnificationFilter = configuration.contentsFilter
        }
    }

    private var provider: AnimatedImageProvider? = nil {
        didSet {
            contents = nil

            if let image {
                provider?
                    .update(for: bounds.size, scale: traitCollection.displayScale, image: image)
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
        if let image {
            provider?.update(for: bounds.size, scale: traitCollection.displayScale, image: image)
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
