import Foundation

/// アニメーションのタイミング計算を行うクラス
public struct AnimationTimingCalculator: Sendable {

    public init() {}

    /// 指定されたタイムスタンプに対応するフレームインデックスを計算
    /// - Parameters:
    ///   - targetTimestamp: 対象のタイムスタンプ
    ///   - indices: 表示フレームのインデックス配列
    ///   - delayTime: フレーム間の時間間隔
    /// - Returns: 対応するフレームインデックス（存在しない場合はnil）
    public func frameIndex(
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

    /// アニメーションの総継続時間を計算
    /// - Parameters:
    ///   - indices: 表示フレームのインデックス配列
    ///   - delayTime: フレーム間の時間間隔
    /// - Returns: 総継続時間（秒）
    public func totalDuration(
        indices: [Int],
        delayTime: Double
    ) -> TimeInterval {
        guard !indices.isEmpty else { return 0 }
        return delayTime * Double(indices.count)
    }

    /// 指定された時間でのアニメーション進行率を計算
    /// - Parameters:
    ///   - currentTime: 現在時刻
    ///   - indices: 表示フレームのインデックス配列
    ///   - delayTime: フレーム間の時間間隔
    /// - Returns: 進行率（0.0〜1.0）
    public func animationProgress(
        at currentTime: TimeInterval,
        indices: [Int],
        delayTime: Double
    ) -> Double {
        let totalDuration = totalDuration(indices: indices, delayTime: delayTime)
        guard totalDuration > 0 else { return 0 }

        let normalizedTime = currentTime.truncatingRemainder(dividingBy: totalDuration)
        return normalizedTime / totalDuration
    }
}
