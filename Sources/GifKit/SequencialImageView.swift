import UIKit

open class SequencialImageView: AnimatableCGImageView {
    public var image: (any SequencialImage)? = nil {
        didSet {
            if let image {
                imageViewModel = SequencialImageViewModel(name: image.name, configuration: configuration)
            }
        }
    }
    
    public var configuration: SequencialImageViewConfiguration = .default {
        didSet {
            if let image {
                imageViewModel = SequencialImageViewModel(name: image.name, configuration: configuration)
            }
        }
    }
    
    private var imageViewModel: SequencialImageViewModel? = nil {
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let image {
            imageViewModel?.update(for: bounds.size, image: image)
        }
    }
    
    open override func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        let index = imageViewModel?.index(for: targetTimestamp)
        if let index, currentIndex != index {
            let newContents = imageViewModel?.image(at: index)?.cgImage
            if let newContents {
                currentIndex = index
                contents = newContents
            }
        }
    }
}
