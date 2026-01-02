public import Foundation
import QuartzCore

/// アニメーション画像の最適なサイズを計算するクラス
/// レンダリングサイズ、メモリ制約、アスペクト比を考慮してサイズを決定
public struct SizeOptimizer: Sendable {
    public init() {}

    /// レンダリングに最適なサイズを計算
    ///
    /// 処理の流れ:
    /// 1. maxSizeとrenderSizeの小さい方を有効サイズとして決定
    /// 2. 元画像サイズを超えないよう制約を適用
    /// 3. アスペクト比を維持してサイズを調整
    /// 4. スケールを適用
    /// 5. メモリ制約に基づいて最終調整
    @concurrent
    public func optimizedSize(
        for renderSize: Size,
        maxSize: Size,
        scale: CGFloat,
        imageSize: Size,
        imageCount: Int = 1,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double = 0.8
    ) async -> Size {
        // 1. 実際の最大サイズを決定（maxSizeとrenderSizeの小さい方）
        let effectiveMaxSize = await min(maxSize, renderSize)
        // 2. 元画像サイズを超えないよう制約を適用
        let constrainedSize = Size(
            width: min(effectiveMaxSize.width, imageSize.width),
            height: min(effectiveMaxSize.height, imageSize.height)
        )
        // 3. アスペクト比を維持してサイズを調整
        let aspectOptimizedSize = await aspectFitSize(of: imageSize, in: constrainedSize)
        // 4. スケールを適用
        let scaledSize = await aspectOptimizedSize.applying(
            CGAffineTransform(scaleX: scale, y: scale)
        )
        // 5. メモリ制約に基づいて最終調整
        let memoryAdjustedSize = await adjustSizeForMemoryConstraints(
            scaledSize,
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage,
            targetMemoryRatio: targetMemoryRatio
        )

        return memoryAdjustedSize
    }

    /// レンダリングサイズが有効かどうかを判定
    /// 幅と高さが両方とも0より大きい場合に有効とする
    @concurrent
    public func isValidRenderSize(_ renderSize: Size) async -> Bool {
        !renderSize.isEmpty
    }

    /// アスペクト比を維持して指定された最大サイズ内に収まるようにサイズを調整
    @concurrent
    private func aspectFitSize(of currentSize: Size, in maxSize: Size) async -> Size {
        let aspectWidth = CGFloat(maxSize.width) / CGFloat(currentSize.width)
        let aspectHeight = CGFloat(maxSize.height) / CGFloat(currentSize.height)
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return await currentSize.applying(transform)
    }

    /// メモリ制約に基づいてサイズを調整
    /// メモリ使用量が制限を超える場合、平方根で縮小率を計算して調整
    @concurrent
    private func adjustSizeForMemoryConstraints(
        _ size: Size,
        imageCount: Int,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double
    ) async -> Size {
        // RGBA（4バイト/ピクセル）でメモリ使用量を計算
        let imageByteCount = size.width * size.height * 4
        let totalMemoryUsage = Double(imageByteCount * imageCount)
        let targetMemoryUsage = maxMemoryUsage * targetMemoryRatio

        if totalMemoryUsage <= targetMemoryUsage {
            return size
        }
        // メモリオーバーの場合、平方根で縮小率を計算（面積ベースの調整）
        let reductionFactor = sqrt(targetMemoryUsage / totalMemoryUsage)
        let transform = CGAffineTransform(scaleX: reductionFactor, y: reductionFactor)
        return await size.applying(transform)
    }

    /// 品質レベル（完全性レベル）を計算
    /// メモリ圧力に基づいて0.0-1.0の範囲で品質を決定
    /// 値が高いほど高品質（フレーム数が多い）
    @concurrent
    public func integrityLevel(
        for imageSize: Size,
        imageCount: Int,
        maxMemoryUsage: Double,
        maxLevelOfIntegrity: Double
    ) async -> Double {
        // RGBA（4バイト/ピクセル）でメモリ使用量を計算
        let imageByteCount = imageSize.width * imageSize.height * 4
        let memoryPressure = Double(imageByteCount * imageCount) / maxMemoryUsage
        // メモリ圧力の逆数で品質を決定（圧力が低いほど高品質）
        return min(1.0 / memoryPressure, maxLevelOfIntegrity)
    }
}
