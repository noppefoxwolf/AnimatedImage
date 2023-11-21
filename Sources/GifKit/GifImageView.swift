import UIKit

open class GifImageView: AnimatableCGImageView {
    public var image: GifImage? = nil {
        didSet {
            contents = nil
            currentIndex = nil
            cache = GifImageViewCache()
            if let image {
                cache?.update(for: bounds.size, image: image)
            }
        }
    }
    
    private var cache: GifImageViewCache? = nil
    private var currentIndex: Int? = nil
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if let image {
            cache?.update(for: bounds.size, image: image)
        }
    }
    
    open override func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        let index = cache?.index(for: targetTimestamp)
        if let index, currentIndex != index {
            let newContents = cache?.image(at: index)?.cgImage
            if let newContents {
                currentIndex = index
                contents = newContents
            }
        }
    }
}
