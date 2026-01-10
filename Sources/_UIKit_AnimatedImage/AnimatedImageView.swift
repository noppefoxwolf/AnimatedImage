public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var animatedImage: AnimatedImage? = nil {
        willSet {
            animatedImage?.cancelCurrentTask()
        }
        didSet {
            contents = nil
            if let animatedImage {
                layer.magnificationFilter = animatedImage.contentsFilter
                animatedImage.update(
                    for: bounds.size,
                    scale: traitCollection.displayScale
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
        animatedImage?.update(
            for: bounds.size,
            scale: traitCollection.displayScale
        )
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
