import Foundation

/// アニメーションのタイミング計算を行うクラス
struct AnimationTimingCalculator: Sendable {

    init() {}

    /// 指定されたタイムスタンプに対応するフレームインデックスを計算
    /// - Parameters:
    ///   - targetTimestamp: 対象のタイムスタンプ
    ///   - indices: 表示フレームのインデックス配列
    ///   - delayTime: フレーム間の時間間隔
    /// - Returns: 対応するフレームインデックス（存在しない場合はnil）
    func frameIndex(
        for targetTimestamp: TimeInterval,
        indices: [Int],
        delayTime: Double
    ) -> Int? {
        guard !indices.isEmpty else { return nil }
        guard delayTime != 0 else { return nil }

        let duration = delayTime * Double(indices.count)
        let timestamp = targetTimestamp.truncatingRemainder(dividingBy: duration)
        let factor = timestamp / duration
        let index = Int(Double(indices.count) * factor)

        // インデックス範囲チェック
        guard index >= 0 && index < indices.count else { return nil }

        return indices[index]
    }
}
