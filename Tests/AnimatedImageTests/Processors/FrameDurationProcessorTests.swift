import Testing

@testable import AnimatedImageCore

@Suite("FrameDurationProcessor テスト")
struct FrameDurationProcessorTests {

    @Test("unclampedDelayTime を優先して利用する")
    func usesUnclampedDelayWhenAvailable() {
        let processor = FrameDurationProcessor()

        let result = processor.process(
            unclampedDelayTime: { 0.2 },
            delayTime: { 0.05 }
        )

        #expect(result == 0.2)
    }

    @Test("delayTime は unclampedDelayTime が nil のときに使用される")
    func fallsBackToDelayTime() {
        let processor = FrameDurationProcessor()

        let result = processor.process(
            unclampedDelayTime: { nil },
            delayTime: { 0.15 }
        )

        #expect(result == 0.15)
    }

    @Test("両方の遅延が nil のときにデフォルト値を返す")
    func returnsDefaultDelayWhenBothValuesNil() {
        let processor = FrameDurationProcessor()

        let result = processor.process(
            unclampedDelayTime: { nil },
            delayTime: { nil }
        )

        #expect(result == processor.defaultDelayTime)
    }

    @Test("最小遅延よりも短い値はデフォルト遅延に丸められる")
    func enforcesMinimumDelayThreshold() {
        let processor = FrameDurationProcessor()

        let result = processor.process(
            unclampedDelayTime: { processor.minimumDelayTime / 2 },
            delayTime: { nil }
        )

        #expect(result == processor.defaultDelayTime)
    }

    @Test("最小遅延丁度の値はそのまま採用される")
    func acceptsMinimumDelay() {
        let processor = FrameDurationProcessor()

        let result = processor.process(
            unclampedDelayTime: { processor.minimumDelayTime },
            delayTime: { nil }
        )

        #expect(result == processor.minimumDelayTime)
    }
}
