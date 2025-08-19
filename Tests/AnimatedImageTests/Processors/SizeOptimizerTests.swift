import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("SizeOptimizer テスト")
struct SizeOptimizerTests {

    @Test("基本的なサイズ最適化")
    func basicSizeOptimization() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: 128, height: 128)
        let maxMemoryUsage: Double = 1024 * 1024 // 1MB

        let renderSize = Size(width: 100, height: 100)
        let imageSize = Size(width: 200, height: 200)

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: 1.0,
            imageSize: imageSize,
            imageCount: 1,
            maxMemoryUsage: maxMemoryUsage
        )

        #expect(optimizedSize.width <= maxSize.width)
        #expect(optimizedSize.height <= maxSize.height)
        #expect(optimizedSize.width <= renderSize.width)
        #expect(optimizedSize.height <= renderSize.height)
    }

    @Test("アスペクト比維持のテスト")
    func aspectRatioMaintenance() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: 1000, height: 1000)
        let maxMemoryUsage: Double = 10 * 1024 * 1024 // 10MB

        // 横長の画像を正方形にフィット
        let renderSize = Size(width: 100, height: 100)
        let imageSize = Size(width: 200, height: 100)

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: 1.0,
            imageSize: imageSize,
            imageCount: 1,
            maxMemoryUsage: maxMemoryUsage
        )

        let originalAspect = Double(imageSize.width) / Double(imageSize.height)
        let optimizedAspect = Double(optimizedSize.width) / Double(optimizedSize.height)
        
        #expect(abs(originalAspect - optimizedAspect) < 0.01)
    }

    @Test("スケール適用のテスト")
    func scaleApplication() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: 1000, height: 1000)
        let maxMemoryUsage: Double = 10 * 1024 * 1024 // 10MB

        let renderSize = Size(width: 100, height: 100)
        let imageSize = Size(width: 50, height: 50)
        let scale: CGFloat = 2.0

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: scale,
            imageSize: imageSize,
            imageCount: 1,
            maxMemoryUsage: maxMemoryUsage
        )

        #expect(optimizedSize.width <= renderSize.width)
        #expect(optimizedSize.height <= renderSize.height)
    }

    @Test("メモリ制約による調整")
    func memoryConstraintAdjustment() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: 1000, height: 1000)
        let maxMemoryUsage: Double = 1024 // 1KB

        let renderSize = Size(width: 500, height: 500)
        let imageSize = Size(width: 500, height: 500)
        let imageCount = 100

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: 1.0,
            imageSize: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage
        )

        #expect(optimizedSize.width < renderSize.width)
        #expect(optimizedSize.height < renderSize.height)
    }

    @Test("品質レベル計算")
    func integrityLevelCalculation() {
        let optimizer = SizeOptimizer()
        let maxMemoryUsage: Double = 1024 * 1024 // 1MB
        let maxLevelOfIntegrity: Double = 0.8

        let imageSize = Size(width: 100, height: 100)
        let imageCount = 10

        let integrityLevel = optimizer.integrityLevel(
            for: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage,
            maxLevelOfIntegrity: maxLevelOfIntegrity
        )

        #expect(integrityLevel > 0.0)
        #expect(integrityLevel <= 1.0)
        #expect(integrityLevel <= maxLevelOfIntegrity)
    }

    @Test("レンダリングサイズの検証")
    func renderSizeValidation() {
        let optimizer = SizeOptimizer()

        #expect(optimizer.isValidRenderSize(Size(width: 100, height: 100)))
        #expect(!optimizer.isValidRenderSize(Size.zero))
        #expect(!optimizer.isValidRenderSize(Size(width: 0, height: 100)))
        #expect(!optimizer.isValidRenderSize(Size(width: 100, height: 0)))
    }

    @Test("元画像サイズを超えない制約")
    func noUpscalingConstraint() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: Int.max, height: Int.max)
        let maxMemoryUsage: Double = 1024 * 1024 * 1024

        let renderSize = Size(width: 200, height: 200)
        let imageSize = Size(width: 100, height: 100)
        let scale: CGFloat = 1.0

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: scale,
            imageSize: imageSize,
            imageCount: 1,
            maxMemoryUsage: maxMemoryUsage
        )

        #expect(optimizedSize.width <= imageSize.width)
        #expect(optimizedSize.height <= imageSize.height)
    }

    @Test("高品質設定での処理")
    func unlimitedConfigurationTest() {
        let optimizer = SizeOptimizer()
        let maxSize = Size(width: Int.max, height: Int.max)
        let maxMemoryUsage: Double = 1024 * 1024 * 1024
        let maxLevelOfIntegrity: Double = 1.0

        let renderSize = Size(width: 1000, height: 1000)
        let imageSize = Size(width: 500, height: 500)
        let imageCount = 50

        let optimizedSize = optimizer.optimizedSize(
            for: renderSize,
            maxSize: maxSize,
            scale: 1.0,
            imageSize: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage
        )

        let integrityLevel = optimizer.integrityLevel(
            for: optimizedSize,
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage,
            maxLevelOfIntegrity: maxLevelOfIntegrity
        )

        #expect(integrityLevel >= 0.5)
    }
}