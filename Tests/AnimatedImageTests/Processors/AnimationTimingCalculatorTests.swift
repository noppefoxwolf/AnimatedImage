import Testing

@testable import AnimatedImageCore

@Suite("AnimationTimingCalculator テスト")
struct AnimationTimingCalculatorTests {

    @Test("基本的なフレームインデックス計算")
    func basicFrameIndexCalculation() {
        let calculator = AnimationTimingCalculator()
        let indices = [0, 1, 2, 3, 4]
        let delayTime = 0.1

        // 最初のフレーム
        let firstIndex = calculator.frameIndex(
            for: 0.0,
            indices: indices,
            delayTime: delayTime
        )
        #expect(firstIndex == 0)

        // 中間のフレーム
        let middleIndex = calculator.frameIndex(
            for: 0.25,
            indices: indices,
            delayTime: delayTime
        )
        #expect(middleIndex != nil)

        // 最後のフレーム付近
        let lastIndex = calculator.frameIndex(
            for: 0.45,
            indices: indices,
            delayTime: delayTime
        )
        #expect(lastIndex != nil)
    }
    
    @Test("エッジケース処理")
    func edgeCaseHandling() {
        let calculator = AnimationTimingCalculator()

        // 空のインデックス配列
        let emptyIndex = calculator.frameIndex(
            for: 1.0,
            indices: [],
            delayTime: 0.1
        )
        #expect(emptyIndex == nil)

        // delayTimeが0
        let zeroDelayIndex = calculator.frameIndex(
            for: 1.0,
            indices: [0, 1],
            delayTime: 0.0
        )
        #expect(zeroDelayIndex == nil)
    }

    @Test("長時間での計算精度")
    func longDurationAccuracy() {
        let calculator = AnimationTimingCalculator()
        let indices = Array(0..<100)  // 100フレーム
        let delayTime = 0.01

        // 複数周期後の計算
        let longTimeIndex = calculator.frameIndex(
            for: 5.5,  // 5.5秒後
            indices: indices,
            delayTime: delayTime
        )

        #expect(longTimeIndex != nil)
        #expect(longTimeIndex! >= 0)
        #expect(longTimeIndex! < indices.count)
    }
}
