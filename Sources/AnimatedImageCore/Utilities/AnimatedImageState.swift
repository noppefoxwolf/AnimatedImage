import CoreGraphics
import Foundation

nonisolated struct AnimatedImageState: Sendable {
    nonisolated struct FrameState: Sendable {
        let indices: [Int]
        let delayTime: TimeInterval

        init(indices: [Int], delayTime: TimeInterval) {
            self.indices = indices
            self.delayTime = delayTime
        }
    }

    let cache: Cache<Int, CGImage>
    private(set) var indices: [Int]
    private(set) var delayTime: TimeInterval

    init(
        cache: Cache<Int, CGImage>,
        indices: [Int] = [],
        delayTime: TimeInterval = 0.1
    ) {
        self.cache = cache
        self.indices = indices
        self.delayTime = delayTime
    }

    mutating func update(with state: FrameState) {
        indices = state.indices
        delayTime = state.delayTime
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
        cache.value(forKey: index)
    }

    func removeAllCachedImages() {
        cache.removeAllObjects()
    }
}
