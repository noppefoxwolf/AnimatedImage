import Foundation
import QuartzCore

/// サイズ最適化を専門に扱うクラス
/// アスペクト比、メモリ制約、スケールを考慮した包括的なサイズ最適化を提供
/// 設定に依存しない純粋な関数型アプローチ
public struct SizeOptimizer: Sendable {
    
    public init() {}
    
    /// メモリ使用量の単位変換ユーティリティ
    private func convertToBytes(_ measurement: Measurement<UnitInformationStorage>) -> Double {
        measurement.converted(to: .bytes).value
    }
    
    /// 最適化されたサイズを計算
    /// アスペクト比、メモリ制約、スケールを考慮した包括的なサイズ最適化
    /// 
    /// - Parameters:
    ///   - renderSize: レンダリングサイズ
    ///   - maxSize: 最大サイズ制約
    ///   - scale: スケール倍率
    ///   - imageSize: 元画像サイズ
    ///   - imageCount: フレーム数
    ///   - maxMemoryUsage: 最大メモリ使用量（バイト）
    ///   - targetMemoryRatio: 目標メモリ使用率 (0.0-1.0)
    /// - Returns: 最適化されたサイズ
    public func optimizedSize(
        for renderSize: Size,
        maxSize: Size,
        scale: CGFloat, 
        imageSize: Size, 
        imageCount: Int = 1,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double = 0.8
    ) -> Size {
        // 設定された最大サイズとレンダリングサイズの制約を適用
        let effectiveMaxSize = min(maxSize, renderSize)
        
        // 元画像サイズを超えないよう制約
        let constrainedSize = Size(
            width: min(effectiveMaxSize.width, imageSize.width),
            height: min(effectiveMaxSize.height, imageSize.height)
        )
        
        // アスペクト比を維持した最適サイズを計算
        let aspectOptimizedSize = aspectFitSize(of: imageSize, in: constrainedSize)
        
        // スケールを適用
        let scaledSize = aspectOptimizedSize.applying(
            CGAffineTransform(scaleX: scale, y: scale)
        )
        
        // メモリ制約を考慮したサイズ調整
        let memoryAdjustedSize = adjustSizeForMemoryConstraints(
            scaledSize, 
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage,
            targetMemoryRatio: targetMemoryRatio
        )
        
        return memoryAdjustedSize
    }
    
    /// レンダリングサイズの検証
    public func isValidRenderSize(_ renderSize: Size) -> Bool {
        !renderSize.isEmpty
    }
    
    /// アスペクト比を維持したサイズ計算
    private func aspectFitSize(of currentSize: Size, in maxSize: Size) -> Size {
        let aspectWidth = CGFloat(maxSize.width) / CGFloat(currentSize.width)
        let aspectHeight = CGFloat(maxSize.height) / CGFloat(currentSize.height)
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
    /// メモリ制約を考慮したサイズ調整
    /// メモリ使用量が制限を超える場合、サイズを縮小して調整します
    private func adjustSizeForMemoryConstraints(
        _ size: Size, 
        imageCount: Int,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double
    ) -> Size {
        let imageByteCount = size.width * size.height * 4
        let totalMemoryUsage = Double(imageByteCount * imageCount)
        let targetMemoryUsage = maxMemoryUsage * targetMemoryRatio
        
        if totalMemoryUsage <= targetMemoryUsage {
            return size
        }
        
        // メモリ制限を超える場合、サイズを縮小
        let reductionFactor = sqrt(targetMemoryUsage / totalMemoryUsage)
        let transform = CGAffineTransform(scaleX: reductionFactor, y: reductionFactor)
        return size.applying(transform)
    }
    
    /// 品質レベルを計算
    /// 
    /// メモリ使用量に基づいて品質レベルを決定します：
    /// - メモリ圧迫度が低い（設定値の半分以下）→ 上限値で制限
    /// - メモリ圧迫度が1.0（設定値と同じ）→ 1.0（全フレーム表示）
    /// - メモリ圧迫度が2.0（設定値の2倍）→ 0.5（半分のフレームを間引き）
    /// 
    /// - Parameters:
    ///   - imageSize: 画像サイズ（optimizedSizeで既に調整済み）
    ///   - imageCount: フレーム数
    ///   - maxMemoryUsage: 最大メモリ使用量（バイト）
    ///   - maxLevelOfIntegrity: 品質の上限値 (0.0-1.0)
    /// - Returns: 品質レベル（0.0〜1.0）
    public func integrityLevel(
        for imageSize: Size, 
        imageCount: Int,
        maxMemoryUsage: Double,
        maxLevelOfIntegrity: Double
    ) -> Double {
        let imageByteCount = imageSize.width * imageSize.height * 4
        let memoryPressure = Double(imageByteCount * imageCount) / maxMemoryUsage
        return min(1.0 / memoryPressure, maxLevelOfIntegrity)
    }
}