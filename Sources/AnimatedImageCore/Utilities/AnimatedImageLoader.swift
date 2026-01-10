public import Foundation

public final class AnimatedImageLoader {
    public static let shared = AnimatedImageLoader()
    
    public struct Key: Hashable {
        public let name: String
        public let size: CGSize
        public let scale: CGFloat
        // FIXME: prepareForDisplayで使われる要素が不足している
    }
    
    // TaskCache
    private let taskCache = Cache<Key, Task<AnimatedImage, Never>>(name: "dev.noppe.animated-image-loader")
    
    private init() {
        taskCache.totalCostLimit = 1024 * 1024 * 50 // 50MB
    }
    
    public func decode(
        _ animatedImage: AnimatedImage,
        layout: (size: CGSize, scale: CGFloat)
    ) async -> AnimatedImage {
        await decodeTask(animatedImage, layout: layout).value
    }
    
    public func decodeTask(
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
        let estimatedCost = AnimatedImage.estimatedMemoryCost(size: layout.size, scale: layout.scale)
        taskCache.insert(task, forKey: key, cost: estimatedCost)
        return task
    }
}



