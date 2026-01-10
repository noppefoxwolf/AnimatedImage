public import Foundation

public final class AnimatedImageLoader {
    public static let shared = AnimatedImageLoader()

    public struct Key: Hashable {
        public let name: String
        public let size: CGSize
        public let scale: CGFloat
        public let configuration: AnimatedImage.Configuration
    }

    // TaskCache
    private let taskCache = Cache<Key, Task<AnimatedImage, Never>>(
        name: "dev.noppe.animated-image-loader"
    )

    private init() {
        let measurement = Measurement<UnitInformationStorage>(value: 50, unit: .megabytes)
        totalCostLimit = Int(measurement.converted(to: .bytes).value)
    }

    public var totalCostLimit: Int {
        get { taskCache.totalCostLimit }
        set { taskCache.totalCostLimit = newValue }
    }

    public func decode(
        _ animatedImage: AnimatedImage,
        layout: (size: CGSize, scale: CGFloat),
        taskPriority: TaskPriority = .background
    ) async -> AnimatedImage {
        await decodeTask(
            animatedImage,
            layout: layout,
            taskPriority: taskPriority
        )
        .value
    }

    public func decodeTask(
        _ animatedImage: AnimatedImage,
        layout: (size: CGSize, scale: CGFloat),
        taskPriority: TaskPriority
    ) -> Task<AnimatedImage, Never> {
        let key = Key(
            name: animatedImage.id,
            size: layout.size,
            scale: layout.scale,
            configuration: animatedImage.configuration
        )

        if let task = taskCache[key] {
            return task
        }
        let task = Task.detached(priority: taskPriority) {
            await animatedImage.prepareForDisplay(
                for: layout.size,
                scale: layout.scale
            )
        }
        let estimatedCost = AnimatedImage.estimatedMemoryCost(
            size: layout.size,
            scale: layout.scale
        )
        taskCache.insert(task, forKey: key, cost: estimatedCost)
        return task
    }
}
