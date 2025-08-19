import Testing

@testable import AnimatedImage

@Suite("FrameDecimator テスト")
struct FrameDecimatorTests {

    @Test("基本的なフレーム間引き")
    func basicDecimation() {
        let decimator = FrameDecimator()
        let delays = [0.1, 0.1, 0.1, 0.1, 0.1]  // 5フレーム、各0.1秒

        let result = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 0.6)

        #expect(!result.displayIndices.isEmpty)
        #expect(result.displayIndices.count <= delays.count)
        #expect(result.delayTime > 0)
        #expect(result.displayIndices == [0,2,4])
    }

    @Test("品質レベル1.0で全フレーム表示")
    func fullIntegrityShowsAllFrames() {
        let decimator = FrameDecimator()
        let delays = [0.1, 0.1, 0.1, 0.1, 0.1]

        let result = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 1.0)

        #expect(result.displayIndices == [0, 1, 2, 3, 4])
        #expect(result.delayTime == 0.1)
    }

    @Test("2フレーム未満は間引きしない")
    func noDecimationForTwoOrFewerFrames() {
        let decimator = FrameDecimator()

        // 1フレームの場合
        let singleFrameResult = decimator.optimizeFrameSelection(
            delays: [0.1],
            levelOfIntegrity: 0.5
        )
        #expect(singleFrameResult.displayIndices == [0])
        #expect(singleFrameResult.delayTime == 0.1)

        // 2フレームの場合
        let twoFrameResult = decimator.optimizeFrameSelection(
            delays: [0.1, 0.1],
            levelOfIntegrity: 0.5
        )
        #expect(twoFrameResult.displayIndices == [0, 1])
        #expect(twoFrameResult.delayTime == 0.1)
    }

    @Test("空の配列の処理")
    func emptyDelaysArray() {
        let decimator = FrameDecimator()

        let result = decimator.optimizeFrameSelection(delays: [], levelOfIntegrity: 0.5)

        #expect(result.displayIndices.isEmpty)
        #expect(result.delayTime == 0.1)  // デフォルト値
    }

    @Test("品質レベルの境界値テスト")
    func levelOfIntegrityBoundaryValues() {
        let decimator = FrameDecimator()
        let delays = Array(repeating: 0.1, count: 10)

        // 品質レベル0.0（最小）
        let minResult = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 0.0)
        #expect(!minResult.displayIndices.isEmpty)
        #expect(minResult.displayIndices.count <= delays.count)

        // 品質レベル1.0（最大）
        let maxResult = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 1.0)
        #expect(maxResult.displayIndices.count == delays.count)

        // 範囲外の値（負の値）
        let negativeResult = decimator.optimizeFrameSelection(
            delays: delays,
            levelOfIntegrity: -0.5
        )
        #expect(!negativeResult.displayIndices.isEmpty)

        // 範囲外の値（1.0を超える値）
        let overResult = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 1.5)
        #expect(overResult.displayIndices.count == delays.count)
    }

    @Test("異なるフレーム時間での動作")
    func variableFrameDelays() {
        let decimator = FrameDecimator()
        let delays = [0.05, 0.1, 0.15, 0.2, 0.1]  // 可変フレーム時間

        let result = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 0.8)

        #expect(!result.displayIndices.isEmpty)
        #expect(result.displayIndices.count <= delays.count)
        #expect(result.delayTime > 0)

        // インデックスが昇順であることを確認
        let sortedIndices = result.displayIndices.sorted()
        #expect(result.displayIndices == sortedIndices)
    }

    @Test("低品質レベルでのフレーム削減")
    func lowIntegrityReducesFrames() {
        let decimator = FrameDecimator()
        let delays = Array(repeating: 0.05, count: 20)  // 高フレームレート

        let highIntegrityResult = decimator.optimizeFrameSelection(
            delays: delays,
            levelOfIntegrity: 0.9
        )
        let lowIntegrityResult = decimator.optimizeFrameSelection(
            delays: delays,
            levelOfIntegrity: 0.3
        )

        // 低品質の方がフレーム数が少ないことを確認
        #expect(lowIntegrityResult.displayIndices.count <= highIntegrityResult.displayIndices.count)
    }

    @Test("VSync候補からの選択")
    func vsyncCandidateSelection() {
        let decimator = FrameDecimator()
        let delays = Array(repeating: 1.0 / 60.0, count: 60)  // 60FPSのフレーム

        let result = decimator.optimizeFrameSelection(delays: delays, levelOfIntegrity: 0.5)

        // 結果のフレーム時間が候補の中から選ばれていることを確認
        let expectedCandidates: Set<Double> = [
            1.0, 1.0 / 2.0, 1.0 / 3.0, 1.0 / 4.0, 1.0 / 5.0, 1.0 / 6.0,
            1.0 / 10.0, 1.0 / 12.0, 1.0 / 15.0, 1.0 / 20.0, 1.0 / 30.0, 1.0 / 60.0,
        ]

        let isValidCandidate = expectedCandidates.contains { candidate in
            abs(candidate - result.delayTime) < 0.001
        }
        #expect(isValidCandidate)
    }

    @Test("Result構造体の初期化")
    func resultInitialization() {
        let indices = [0, 2, 4, 6]
        let delayTime = 0.1

        let result = FrameDecimator.Result(displayIndices: indices, delayTime: delayTime)

        #expect(result.displayIndices == indices)
        #expect(result.delayTime == delayTime)
    }
}
