public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var image: AnimatedImage? = nil {
        willSet {
            guard image !== newValue else { return }
            decodedImage = nil
            currentFrameIndex = nil
            contents = nil
        }
        didSet {
            if let image {
                if image.image(at: 0) != nil {
                    decodedImage = image
                } else {
                    decode(
                        AnimatedImageLoader.shared,
                        decodeImage: image,
                        layout: (bounds.size, traitCollection.displayScale)
                    )
                }
            }
            setNeedsDisplay()
        }
    }

    private var decodeTask: Task<Void, Never>? = nil

    private var decodedImage: AnimatedImage? = nil {
        didSet {
            setNeedsDisplay()
        }
    }

    private var currentFrameIndex: Int? = nil
    
    public var adjustAnimatedImageForSize: Bool = true

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let image, adjustAnimatedImageForSize {
            decode(
                AnimatedImageLoader.shared,
                decodeImage: image,
                layout: (bounds.size, traitCollection.displayScale)
            )
        }
    }
    
    func decode(
        _ imageLoader: AnimatedImageLoader,
        decodeImage: AnimatedImage,
        layout: (CGSize, CGFloat)
    ) {
        decodeTask = Task {
            decodedImage = await imageLoader.decode(decodeImage, layout: layout)
        }
    }

    func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> (index: Int, CGImage)? {
        let index = decodedImage?.index(for: targetTimestamp)
        guard let index, currentFrameIndex != index else { return nil }
        let image = decodedImage?.image(at: index)
        guard let image else { return nil }
        return (index, image)
    }

    open override func updateContents(for targetTimestamp: TimeInterval) {
        if let (index, image) = contentsForTimestamp(targetTimestamp) {
            self.currentFrameIndex = index
            self.contents = image
        }
    }
}
