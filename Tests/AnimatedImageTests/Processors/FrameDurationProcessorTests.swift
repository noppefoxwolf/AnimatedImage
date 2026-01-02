import Testing

@testable import AnimatedImageCore

@Suite("FrameDurationProcessor テスト")
struct FrameDurationProcessorTests {

    @Test("unclampedDelayTime を優先して利用する")
    func usesUnclampedDelayWhenAvailable() async {
        let processor = FrameDurationProcessor()

        let result = await processor.process(
            unclampedDelayTime: { 0.2 },
            delayTime: { 0.05 }
        )

        #expect(result == 0.2)
    }

    @Test("delayTime は unclampedDelayTime が nil のときに使用される")
    func fallsBackToDelayTime() async {
        let processor = FrameDurationProcessor()

        let result = await processor.process(
            unclampedDelayTime: { nil },
            delayTime: { 0.15 }
        )

        #expect(result == 0.15)
    }

    @Test("両方の遅延が nil のときにデフォルト値を返す")
    func returnsDefaultDelayWhenBothValuesNil() async {
        let processor = FrameDurationProcessor()

        let result = await processor.process(
            unclampedDelayTime: { nil },
            delayTime: { nil }
        )

        #expect(result == processor.defaultDelayTime)
    }

    @Test("最小遅延よりも短い値はデフォルト遅延に丸められる")
    func enforcesMinimumDelayThreshold() async {
        let processor = FrameDurationProcessor()

        let result = await processor.process(
            unclampedDelayTime: { processor.minimumDelayTime / 2 },
            delayTime: { nil }
        )

        #expect(result == processor.defaultDelayTime)
    }

    @Test("最小遅延丁度の値はそのまま採用される")
    func acceptsMinimumDelay() async {
        let processor = FrameDurationProcessor()

        let result = await processor.process(
            unclampedDelayTime: { processor.minimumDelayTime },
            delayTime: { nil }
        )

        #expect(result == processor.minimumDelayTime)
    }
}
