import Foundation

/// アニメーションフレームの間引き処理を行うクラス
/// VSync同期とメモリ使用量を考慮してフレーム数を最適化する
public struct FrameDecimator: Sendable {

    /// フレーム間引きの結果
    public struct Result: Sendable {
        /// 表示するフレームのインデックス配列
        public let displayIndices: [Int]
        /// 最適化されたフレーム間隔（秒）
        public let delayTime: Double

        public init(displayIndices: [Int], delayTime: Double) {
            self.displayIndices = displayIndices
            self.delayTime = delayTime
        }
    }

    /// VSync候補フレームレート（1/秒）
    private static let vsyncIntervals: [Double] = [
        1.000,  // 1 FPS
        0.500,  // 2 FPS
        0.333,  // 3 FPS
        0.250,  // 4 FPS
        0.200,  // 5 FPS
        0.166,  // 6 FPS
        0.100,  // 10 FPS
        0.083,  // 12 FPS
        0.066,  // 15 FPS
        0.050,  // 20 FPS
        0.033,  // 30 FPS
        0.016,  // 60 FPS
    ]

    public init() {}

    /// フレームの間引き処理を実行する
    /// - Parameters:
    ///   - delays: 各フレームの表示時間（秒）
    ///   - levelOfIntegrity: 品質レベル（0.0〜1.0）。1.0で全フレーム表示、0.0で最小フレーム
    /// - Returns: 間引き結果
    public func optimizeFrameSelection(
        delays: [Double],
        levelOfIntegrity: Double
    ) -> Result {
        // 品質レベルを0.0〜1.0に制限
        let levelOfIntegrity = max(0.0, min(1.0, levelOfIntegrity))

        // 各フレームが表示されるはずのタイムスタンプを計算
        let timestamps = calculateRunningSum(delays)

        // デフォルト値を設定
        var resultDelayTime: Double = 0.1
        var displayIndices: [Int] = Array(delays.indices)

        // 2フレーム未満は間引きしない
        if delays.count <= 2 {
            return Result(
                displayIndices: displayIndices,
                delayTime: delays.first ?? resultDelayTime
            )
        }

        // 品質レベルが最大の場合は間引きしない
        if levelOfIntegrity == 1.0 {
            return Result(
                displayIndices: displayIndices,
                delayTime: delays.first ?? resultDelayTime
            )
        }

        // 各VSync候補について最適解を探す
        for candidateDelayTime in Self.vsyncIntervals {
            let decimationResult = calculateDecimationForInterval(
                timestamps: timestamps,
                delayTime: candidateDelayTime,
                levelOfIntegrity: levelOfIntegrity
            )

            if decimationResult.isValid {
                displayIndices = decimationResult.indices
                resultDelayTime = candidateDelayTime
                break
            }
        }

        return Result(
            displayIndices: displayIndices,
            delayTime: resultDelayTime
        )
    }

    /// 指定されたフレーム間隔での間引き計算を実行
    private func calculateDecimationForInterval(
        timestamps: [Double],
        delayTime: Double,
        levelOfIntegrity: Double
    ) -> (indices: [Int], isValid: Bool) {
        // 候補フレーム時間での各フレームのVSync位置を計算
        let vsyncIndices = timestamps.map { Int($0 / delayTime) }
        let uniqueVsyncIndices = Set(vsyncIndices).sorted()

        // 必要な表示フレーム数を計算
        let totalFrameCount = vsyncIndices.count
        let needsDisplayFrameCount = Int(Double(totalFrameCount) * levelOfIntegrity)
        let displayFrameCount = uniqueVsyncIndices.count

        // フレーム数が条件を満たすかチェック
        let isValid = displayFrameCount >= needsDisplayFrameCount

        guard isValid else {
            return ([], false)
        }

        // 表示するフレームインデックスを選択
        let selectedIndices = selectDisplayIndices(
            vsyncIndices: vsyncIndices,
            uniqueVsyncCount: uniqueVsyncIndices.count
        )

        return (selectedIndices, true)
    }

    /// 表示するフレームインデックスを選択
    private func selectDisplayIndices(
        vsyncIndices: [Int],
        uniqueVsyncCount: Int
    ) -> [Int] {
        var displayIndices: [Int] = []
        var oldIndex = 0
        var newIndex = 0

        while newIndex <= uniqueVsyncCount && oldIndex < vsyncIndices.count {
            if newIndex <= vsyncIndices[oldIndex] {
                displayIndices.append(oldIndex)
                newIndex += 1
            } else {
                oldIndex += 1
            }
        }

        return displayIndices
    }

    /// 累積和を計算
    private func calculateRunningSum(_ values: [Double]) -> [Double] {
        var result: [Double] = []
        var sum: Double = 0
        for value in values {
            sum += value
            result.append(sum)
        }
        return result
    }
}
