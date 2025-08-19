import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("CGImageProcessor テスト")
struct CGImageProcessorTests {
    
    let processor = CGImageProcessor()
    
    @Test("アスペクト比フィット計算")
    func aspectFitSizeCalculation() async {
        // 元サイズより小さくフィット
        let currentSize = CGSize(width: 200, height: 100)
        let maxSize = CGSize(width: 100, height: 100)
        let fitSize = await processor.aspectFitSize(for: currentSize, maxSize: maxSize)
        
        #expect(fitSize.width == 100)
        #expect(fitSize.height == 50)
        
        // 正方形の画像を長方形にフィット
        let squareSize = CGSize(width: 100, height: 100)
        let rectMaxSize = CGSize(width: 200, height: 100)
        let squareFitSize = await processor.aspectFitSize(for: squareSize, maxSize: rectMaxSize)
        
        #expect(squareFitSize.width == 100)
        #expect(squareFitSize.height == 100)
    }
    
    @Test("画像リサイズ")
    func imageResize() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let newSize = CGSize(width: 50, height: 50)
        
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
            newSize: CGSize(width: -10, height: 50),
            interpolationQuality: .default
        )
        #expect(negativeSizeResult == nil)
    }
    
    @Test("画像デコード処理")
    func imageDecoding() async {
        let originalImage = createTestImage(width: 200, height: 200)
        let targetSize = CGSize(width: 100, height: 100)
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            scale: 1.0,
            interpolationQuality: .default
        )
        
        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 100)
        #expect(decodedImage?.height == 100)
    }
    
    @Test("スケール適用でのデコード")
    func decodingWithScale() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let targetSize = CGSize(width: 50, height: 50)
        let scale: CGFloat = 2.0
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            scale: scale,
            interpolationQuality: .default
        )
        
        #expect(decodedImage != nil)
        #expect(decodedImage?.width == 100) // 50 * 2.0
        #expect(decodedImage?.height == 100) // 50 * 2.0
    }
    
    @Test("既に適切なサイズの画像処理")
    func decodingAlreadyCorrectSize() async {
        let originalImage = createTestImage(width: 50, height: 50)
        let targetSize = CGSize(width: 100, height: 100)
        
        // usePreparingForDisplay = true の場合、元画像がそのまま返される
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: true,
            scale: 1.0,
            interpolationQuality: .default
        )
        
        #expect(decodedImage === originalImage)
    }
    
    @Test("強制リサイズ")
    func forcedResize() async {
        let originalImage = createTestImage(width: 50, height: 50)
        let targetSize = CGSize(width: 100, height: 100)
        
        // usePreparingForDisplay = false の場合、必ずリサイズされる
        // ただし、元サイズより大きくはならない
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            scale: 1.0,
            interpolationQuality: .default
        )
        
        #expect(decodedImage !== originalImage)
        #expect(decodedImage?.width == 50) // 元サイズのまま
        #expect(decodedImage?.height == 50)
    }
    
    @Test("元サイズより大きくリサイズしない")
    func noUpscaling() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let targetSize = CGSize(width: 200, height: 200)
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            scale: 1.0,
            interpolationQuality: .default
        )
        
        #expect(decodedImage?.width == 100) // 元サイズより大きくならない
        #expect(decodedImage?.height == 100)
    }
    
    @Test("片方の軸のみ大きい場合の処理")
    func partialUpscalingPrevention() async {
        let originalImage = createTestImage(width: 100, height: 50)
        let targetSize = CGSize(width: 200, height: 25) // 幅は大きく、高さは小さく
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            scale: 1.0,
            interpolationQuality: .default
        )
        
        // 制約されたサイズ: (100, 25) でアスペクト比維持すると (50, 25)
        #expect(decodedImage?.width == 50)
        #expect(decodedImage?.height == 25)
    }
    
    // テスト用のCGImageを作成
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
        
        // 白で塗りつぶし
        context.setFillColor(CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        return context.makeImage()!
    }
}
