import CoreGraphics
import Foundation
import QuartzCore

/// アニメーション画像プロバイダーの設定を管理する構造体
/// メモリ使用量、画像サイズ、品質設定などを制御します
public struct AnimatedImageProviderConfiguration: Sendable {
    /// 無制限設定：最大限のメモリとサイズを許可し、最高品質で処理
    public static var unlimited: Self {
        Self(
            maxMemoryUsage: .init(value: 1, unit: .gigabytes),
            maxSize: Size(width: Int.max, height: Int.max),
            maxLevelOfIntegrity: 1,
            interpolationQuality: .high,
            contentsFilter: .trilinear,
            taskPriority: .userInitiated
        )
    }

    /// デフォルト設定：バランスの取れたメモリ使用量と品質設定
    public static var `default`: Self {
        Self(
            maxMemoryUsage: .init(value: 1, unit: .megabytes),
            maxSize: Size(width: 128, height: 128),
            maxLevelOfIntegrity: 0.8,
            interpolationQuality: .default,
            contentsFilter: .linear,
            taskPriority: .medium
        )
    }

    /// パフォーマンス設定：低メモリ・低品質でパフォーマンス重視
    public static var performance: Self {
        Self(
            maxMemoryUsage: .init(value: 20, unit: .kilobytes),
            maxSize: Size(width: 32, height: 32),
            maxLevelOfIntegrity: 0.25,
            interpolationQuality: .none,
            contentsFilter: .nearest,
            taskPriority: .low
        )
    }

    /// 最大メモリ使用量
    public var maxMemoryUsage: Measurement<UnitInformationStorage>
    /// 最大画像サイズ
    public var maxSize: Size
    /// 品質の完全性レベル（0.0-1.0）
    public var maxLevelOfIntegrity: Double
    /// 画像補間品質
    public var interpolationQuality: CGInterpolationQuality
    /// レイヤーコンテンツフィルター
    public var contentsFilter: CALayerContentsFilter
    /// タスク優先度
    public var taskPriority: TaskPriority
}
