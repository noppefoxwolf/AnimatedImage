import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("AnimatedImageState テスト")
struct AnimatedImageStateTests {

    @Test("基本的なフレームインデックス計算")
    func basicFrameIndexCalculation() {
        let state = makeState(indices: [0, 1, 2, 3, 4], delayTime: 0.1)

        #expect(state.frameIndex(for: 0.0) == 0)
        #expect(state.frameIndex(for: 0.25) == 2)
        #expect(state.frameIndex(for: 0.45) == 4)
    }

    @Test("エッジケース処理")
    func edgeCaseHandling() {
        let emptyState = makeState(indices: [], delayTime: 0.1)
        #expect(emptyState.frameIndex(for: 1.0) == nil)

        let zeroDelayState = makeState(indices: [0, 1], delayTime: 0.0)
        #expect(zeroDelayState.frameIndex(for: 1.0) == nil)
    }

    @Test("長時間での計算精度")
    func longDurationAccuracy() {
        let indices = Array(0..<100)
        let state = makeState(indices: indices, delayTime: 0.01)

        let longTimeIndex = state.frameIndex(for: 5.5)

        #expect(longTimeIndex == 50)
    }

    @Test("保存した画像を取得できる")
    func storedImageCanBeRetrieved() {
        let image = makeImage()
        let state = AnimatedImageState(
            name: "TestState",
            size: Size(width: 10, height: 10),
            indices: [0],
            images: [0: image],
            totalCostLimit: 1024 * 1024
        )

        #expect(state.image(at: 0) === image)
    }

    private func makeState(indices: [Int], delayTime: TimeInterval) -> AnimatedImageState {
        AnimatedImageState(
            name: "TestState",
            size: Size(width: 10, height: 10),
            indices: indices,
            delayTime: delayTime,
            images: [:],
            totalCostLimit: 1024 * 1024
        )
    }

    private func makeImage() -> CGImage {
        let context = CGContext(
            data: nil,
            width: 10,
            height: 10,
            bitsPerComponent: 8,
            bytesPerRow: 10 * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}
