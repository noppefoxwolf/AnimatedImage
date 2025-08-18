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
            currentIndex = nil
            
            if let image {
                imageViewModel?.update(for: bounds.size, image: image)
            }
            
            setNeedsDisplay()
        }
    }
    private var currentIndex: Int? = nil
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            imageViewModel?.task?.cancel()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let image {
            imageViewModel?.update(for: bounds.size, image: image)
        }
    }
    
    open override func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        let index = imageViewModel?.index(for: targetTimestamp)
        if let index, currentIndex != index {
            let newContents = imageViewModel?.makeImage(at: index)?.cgImage
            if let newContents {
                currentIndex = index
                contents = newContents
            }
        }
    }
}
