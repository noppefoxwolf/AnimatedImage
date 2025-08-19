import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("ImageProcessor テスト")
struct ImageProcessorTests {

    @Test("基本的な画像処理")
    func basicImageProcessing() async {
        let configuration = AnimatedImageProviderConfiguration.default
        let processor = ImageProcessor(configuration: configuration)

        let renderSize = Size(width: 100, height: 100)

        #expect(processor.isValidRenderSize(renderSize))
        #expect(!processor.isValidRenderSize(.zero))

        let optimizedSize = processor.optimizedSize(
            for: renderSize,
            scale: 1.0,
            imageSize: Size(width: 200, height: 200),
            imageCount: 1
        )
        #expect(optimizedSize.width <= configuration.maxSize.width)
        #expect(optimizedSize.height <= configuration.maxSize.height)
    }

    @Test("フレーム設定計算")
    func frameConfigurationCalculation() {
        let configuration = AnimatedImageProviderConfiguration.default
        let processor = ImageProcessor(configuration: configuration)

        let mockImage = MockAnimatedImage(frameCount: 10, delayTime: 0.1)
        let frameConfig = processor.frameConfiguration(
            for: Size(width: 100, height: 100),
            imageCount: 10,
            scale: 1,
            image: mockImage
        )

        #expect(!frameConfig.indices.isEmpty)
        #expect(frameConfig.delayTime > 0)
        #expect(frameConfig.optimizedSize.width == 100)
        #expect(frameConfig.optimizedSize.height == 100)
    }

    @Test("個別画像作成")
    func individualImageCreation() async {
        let configuration = AnimatedImageProviderConfiguration.default
        let processor = ImageProcessor(configuration: configuration)

        let mockImage = MockAnimatedImage(frameCount: 5, delayTime: 0.1)
        let image = await processor.createAndCacheImage(
            image: mockImage,
            size: Size(width: 50, height: 50),
            index: 0,
            scale: 1,
            interpolationQuality: .default
        )

        #expect(image != nil)
    }
}

// テスト用のモック
private final class MockAnimatedImage: AnimatedImage, @unchecked Sendable {
    private let frameCount: Int
    private let delayTime: Double

    let name: String = "MockImage"

    init(frameCount: Int, delayTime: Double) {
        self.frameCount = frameCount
        self.delayTime = delayTime
    }

    nonisolated var imageCount: Int {
        frameCount
    }

    nonisolated func delayTime(at index: Int) -> Double {
        delayTime
    }

    nonisolated func image(at index: Int) -> CGImage? {
        guard index >= 0 && index < frameCount else { return nil }

        // 簡単なテスト用CGImageを作成
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: 10,
            height: 10,
            bitsPerComponent: 8,
            bytesPerRow: 40,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )

        return context?.makeImage()
    }
}
