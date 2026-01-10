import CoreGraphics
import Foundation

nonisolated struct AnimatedImageState: Sendable {
    let storage: Cache<Int, CGImage>
    let size: Size
    let indices: [Int]
    let delayTime: TimeInterval

    init(
        name: String,
        size: Size,
        indices: [Int],
        delayTime: TimeInterval = 0.1,
        images: [Int: CGImage],
        totalCostLimit: Int
    ) {
        self.storage = Cache<Int, CGImage>(name: name)
        self.size = size
        self.indices = indices
        self.delayTime = delayTime
        insertImages(images)
        storage.totalCostLimit = totalCostLimit
    }

    func frameIndex(for targetTimestamp: TimeInterval) -> Int? {
        guard !indices.isEmpty else { return nil }
        guard delayTime != 0 else { return nil }

        let duration = delayTime * TimeInterval(indices.count)
        let timestamp = targetTimestamp.truncatingRemainder(dividingBy: duration)
        let factor = timestamp / duration
        let index = Int(TimeInterval(indices.count) * factor)

        guard indices.indices.contains(index) else { return nil }
        return indices[index]
    }

    func image(at index: Int) -> CGImage? {
        storage.value(forKey: index)
    }

    func insert(_ image: CGImage, for index: Int) {
        storage.insert(image, forKey: index)
    }

    func insertImages(_ images: [Int: CGImage]) {
        for (index, image) in images {
            let cost = image.bytesPerRow * image.height
            storage.insert(image, forKey: index, cost: cost)
        }
    }
}
