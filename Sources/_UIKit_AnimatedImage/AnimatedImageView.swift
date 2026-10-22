public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var image: AnimatedImage? = nil {
        willSet {
            guard image !== newValue else { return }
            decodeTask?.cancel()
            decodeTask = nil
            lastDecodeRequest = nil
            decodedImage = nil
            currentFrameIndex = nil
            contents = nil
        }
        didSet {
            guard image !== oldValue else { return }
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

    private(set) var decodeTask: Task<Void, Never>? = nil

    private struct DecodeRequest: Equatable {
        let image: ObjectIdentifier
        let loader: ObjectIdentifier
        let size: CGSize
        let scale: CGFloat
    }

    private var lastDecodeRequest: DecodeRequest?

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
        guard layout.0.width > 0, layout.0.height > 0, layout.1 > 0 else { return }

        let request = DecodeRequest(
            image: ObjectIdentifier(decodeImage),
            loader: ObjectIdentifier(imageLoader),
            size: layout.0,
            scale: layout.1
        )
        guard lastDecodeRequest != request else { return }
        lastDecodeRequest = request
        decodeTask?.cancel()
        decodeTask = Task { [weak self] in
            let decodedImage = await imageLoader.decode(decodeImage, layout: layout)
            guard !Task.isCancelled, let self else { return }
            self.decodedImage = decodedImage
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
