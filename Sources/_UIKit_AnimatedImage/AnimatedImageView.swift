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
                decode(
                    AnimatedImageLoader.shared,
                    decodeImage: animatedImage,
                    // FIXME: サイズは適当な値を入れてる
                    layout: (CGSize(width: 60, height: 60), 3)
                )
            }
            setNeedsDisplay()
        }
    }
    
    private var decodeTask: Task<Void, Never>? = nil
    
    private var decodedAnimatedImage: AnimatedImage? = nil {
        didSet {
            // TODO: 比較して更新されているかチェック
            setNeedsDisplay()
        }
    }
    
    public var optimizeDecodeForSize: Bool = true
    
    private var currentFrameIndex: Int = 0
    
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
        
        if optimizeDecodeForSize {
            if let animatedImage {
                decode(
                    AnimatedImageLoader.shared,
                    decodeImage: animatedImage,
                    layout: (bounds.size, traitCollection.displayScale)
                )
            }
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


final class AnimatedImageLoader {
    static let shared = AnimatedImageLoader()
    
    struct Key: Hashable {
        let name: String
        let size: CGSize
        let scale: CGFloat
    }
    
    // TaskCache
    var taskCache: [Key : Task<AnimatedImage, Never>] = [:]
    
    func decode(
        _ animatedImage: AnimatedImage,
        layout: (size: CGSize, scale: CGFloat)
    ) async -> AnimatedImage {
        await decodeTask(animatedImage, layout: layout).value
    }
    
    func decodeTask(
        _ animatedImage: AnimatedImage,
        layout: (size: CGSize, scale: CGFloat)
    ) -> Task<AnimatedImage, Never> {
        let key = Key(
            name: animatedImage.id,
            size: layout.size,
            scale: layout.scale
        )
        
        if let task = taskCache[key] {
            return task
        }
        let task = Task {
            await animatedImage.prepareForDisplay(
                for: layout.size,
                scale: layout.scale
            )
        }
        taskCache[key] = task
        return task
    }
}



