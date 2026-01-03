import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("CGImageProcessor テスト")
struct CGImageProcessorTests {

    let processor = CGImageProcessor()

    @Test("画像リサイズ")
    func imageResize() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let newSize = Size(width: 50, height: 50)

        let resizedImage = await processor.resize(
            image: originalImage,
            newSize: newSize,
            interpolationQuality: .default
        )

        #expect(resizedImage != nil)
        #expect(resizedImage?.width == 50)
        #expect(resizedImage?.height == 50)
    }

    @Test("無効なサイズでのリサイズ")
    func resizeWithInvalidSize() async {
        let originalImage = createTestImage(width: 100, height: 100)

        // ゼロサイズでのリサイズ
        let zeroSizeResult = await processor.resize(
            image: originalImage,
            newSize: .zero,
            interpolationQuality: .default
        )
        #expect(zeroSizeResult == nil)

        // 負のサイズでのリサイズ
        let negativeSizeResult = await processor.resize(
            image: originalImage,
            newSize: Size(width: -10, height: 50),
            interpolationQuality: .default
        )
        #expect(negativeSizeResult == nil)
    }

    @Test("画像デコード処理")
    func imageDecoding() async {
        let originalImage = createTestImage(width: 200, height: 200)
        let targetSize = Size(width: 100, height: 100)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 100)
        #expect(decodedImage?.height == 100)
    }

    @Test("スケール適用でのデコード")
    func decodingWithScale() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let targetSize = Size(width: 50, height: 50)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 50)
        #expect(decodedImage?.height == 50)
    }

    @Test("強制リサイズ")
    func forcedResize() async {
        let originalImage = createTestImage(width: 50, height: 50)
        let targetSize = Size(width: 100, height: 100)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage !== originalImage)
        #expect(decodedImage?.width == 100)
        #expect(decodedImage?.height == 100)
    }

    @Test("元サイズより大きくリサイズしない")
    func noUpscaling() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let targetSize = Size(width: 200, height: 200)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage?.width == 200)
        #expect(decodedImage?.height == 200)
    }

    @Test("片方の軸のみ大きい場合の処理")
    func partialUpscalingPrevention() async {
        let originalImage = createTestImage(width: 100, height: 50)
        let targetSize = Size(width: 200, height: 25)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage?.width == 200)
        #expect(decodedImage?.height == 25)
    }

    @Test("グレースケール画像のデコード")
    func grayscaleImageDecoding() async {
        let originalImage = createGrayscaleTestImage(width: 80, height: 80)
        let targetSize = Size(width: 40, height: 40)

        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 40)
        #expect(decodedImage?.height == 40)
    }

    @Test("グレースケール+アルファ画像のデコード")
    func grayscaleWithAlphaDecoding() async {
        let base = createGrayscaleTestImage(width: 64, height: 64)
        let mask = createGrayscaleMask(width: 64, height: 64)
        let maskedImage = base.masking(mask)

        #expect(maskedImage != nil)

        let targetSize = Size(width: 32, height: 32)
        let decodedImage = await processor.decoded(
            image: maskedImage!,
            for: targetSize,
            interpolationQuality: .default
        )

        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 32)
        #expect(decodedImage?.height == 32)
    }

    private func createTestImage(width: Int, height: Int) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!

        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        return context.makeImage()!
    }

    private func createGrayscaleTestImage(width: Int, height: Int) -> CGImage {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let pixelCount = width * height
        let data = Data(repeating: 0x80, count: pixelCount)  // mid-gray
        let provider = CGDataProvider(data: data as CFData)!

        let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: width,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(),
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )!

        return image
    }

    private func createGrayscaleMask(width: Int, height: Int) -> CGImage {
        // Create a simple mask with constant mid alpha.
        let pixelCount = width * height
        let data = Data(repeating: 0x80, count: pixelCount)  // 128 alpha
        let provider = CGDataProvider(data: data as CFData)!
        let mask = CGImage(
            maskWidth: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 8,
            bytesPerRow: width,
            provider: provider,
            decode: nil,
            shouldInterpolate: false
        )!
        return mask
    }
}
