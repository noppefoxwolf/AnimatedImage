public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var image: (any AnimatedImage)? = nil {
        didSet {
            if let image {
                imageViewModel = AnimatedImageViewModel(name: image.name, configuration: configuration)
            }
        }
    }
    
    public var configuration: AnimatedImageViewConfiguration = .default {
        didSet {
            if let image {
                imageViewModel = AnimatedImageViewModel(name: image.name, configuration: configuration)
            }
            layer.magnificationFilter = configuration.contentsFilter
        }
    }
    
    private var imageViewModel: AnimatedImageViewModel? = nil {
        didSet {
            contents = nil
            
            if let image {
                imageViewModel?.update(for: bounds.size, scale: traitCollection.displayScale, image: image)
            }
            
            setNeedsDisplay()
        }
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            imageViewModel?.task?.cancel()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let image {
            imageViewModel?.update(for: bounds.size, scale: traitCollection.displayScale, image: image)
        }
    }
    
    open override func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        if let image = imageViewModel?.contentsForTimestamp(targetTimestamp) {
            contents = image
        }
    }
}
