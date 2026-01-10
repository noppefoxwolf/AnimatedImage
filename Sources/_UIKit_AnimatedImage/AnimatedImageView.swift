public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var animatedImage: AnimatedImage? = nil {
        willSet {
            decodedAnimatedImage = nil
            contents = nil
        }
        didSet {
            if let animatedImage {
                if animatedImage.image(at: 0) != nil {
                    decodedAnimatedImage = animatedImage
                } else {
                    decode(
                        AnimatedImageLoader.shared,
                        decodeImage: animatedImage,
                        layout: (bounds.size, traitCollection.displayScale)
                    )
                }
            }
            setNeedsDisplay()
        }
    }
    
    private var decodeTask: Task<Void, Never>? = nil
    
    private var decodedAnimatedImage: AnimatedImage? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var currentFrameIndex: Int? = nil
    
    func decode(
        _ imageLoader: AnimatedImageLoader,
        decodeImage: AnimatedImage,
        layout: (CGSize, CGFloat)
    ) {
        decodeTask = Task {
            decodedAnimatedImage = await imageLoader.decode(decodeImage, layout: layout)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let animatedImage {
            decode(
                AnimatedImageLoader.shared,
                decodeImage: animatedImage,
                layout: (bounds.size, traitCollection.displayScale)
            )
        }
    }

    func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> (index: Int, CGImage)? {
        let index = decodedAnimatedImage?.index(for: targetTimestamp)
        guard let index, currentFrameIndex != index else { return nil }
        let image = decodedAnimatedImage?.image(at: index)
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


