public import AnimatedImageCore
public import UIKit

open class AnimatedImageView: AnimatableCGImageView {
    public var animatedImage: AnimatedImage? = nil {
        willSet {
            preparingTask?.cancel()
        }
        didSet {
            contents = nil
            if let animatedImage {
                preparingTask = Task {
                    let a = await animatedImage.prepareForDisplay(
                        renderSize: bounds.size,
                        scale: traitCollection.displayScale
                    )
                    preparedAnimatedImage = a
                }
            }
            setNeedsDisplay()
        }
    }
    
    private var preparingTask: Task<Void, Never>? = nil
    private var preparedAnimatedImage: AnimatedImage? = nil
    private var currentFrameIndex: Int = 0

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil {
            preparingTask?.cancel()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutChanged = true
        if layoutChanged {
            preparingTask = Task {
                let a = await animatedImage?.prepareForDisplay(
                    renderSize: bounds.size,
                    scale: traitCollection.displayScale
                )
                preparedAnimatedImage = a
            }
        }
    }
    
    func contents(at index: Int) -> CGImage? {
        let image = preparedAnimatedImage?.image(at: index)
        if image != nil {
            currentFrameIndex = index
        }
        return image
    }

    func contentsForTimestamp(_ targetTimestamp: TimeInterval) -> CGImage? {
        let index = preparedAnimatedImage?.index(for: targetTimestamp)
        guard let index, currentFrameIndex != index else { return nil }
        return contents(at: index)
    }

    open override func willUpdateContents(
        _ contents: inout CGImage?,
        for targetTimestamp: TimeInterval
    ) {
        if let image = contentsForTimestamp(targetTimestamp) {
            contents = image
        }
    }
}
