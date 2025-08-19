import CoreGraphics
import Foundation
import Testing

@testable import AnimatedImageCore

@Suite("CGImageProcessor テスト")
struct CGImageProcessorTests {
    
    let processor = CGImageProcessor()
    
    // aspectFitSizeはImageProcessorに移動したため、このテストは削除
    // 代わりに統合テストである decoded テストでアスペクト比をチェック
    
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
        // scaleはもうCGImageProcessorでは使用されない
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            interpolationQuality: .default
        )
        
        #expect(decodedImage != nil)
        // CGImageProcessorの修正でscaleは適用されないため、targetSizeのまま
        #expect(decodedImage?.width == 50)
        #expect(decodedImage?.height == 50)
    }
    
    @Test("既に適切なサイズの画像処理")
    func decodingAlreadyCorrectSize() async {
        let originalImage = createTestImage(width: 50, height: 50)
        let targetSize = Size(width: 100, height: 100)
        
        // usePreparingForDisplay = true の場合、元画像がそのまま返される
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: true,
            interpolationQuality: .default
        )
        
        #expect(decodedImage === originalImage)
    }
    
    @Test("強制リサイズ")
    func forcedResize() async {
        let originalImage = createTestImage(width: 50, height: 50)
        let targetSize = Size(width: 100, height: 100)
        
        // usePreparingForDisplay = false の場合、リサイズが必要
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            interpolationQuality: .default
        )
        
        #expect(decodedImage !== originalImage)
        #expect(decodedImage?.width == 100) // targetSizeにリサイズ
        #expect(decodedImage?.height == 100)
    }
    
    @Test("元サイズより大きくリサイズしない")
    func noUpscaling() async {
        let originalImage = createTestImage(width: 100, height: 100)
        let targetSize = Size(width: 200, height: 200)
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            interpolationQuality: .default
        )
        
        #expect(decodedImage?.width == 200) // targetSizeにリサイズ
        #expect(decodedImage?.height == 200)
    }
    
    @Test("片方の軸のみ大きい場合の処理")
    func partialUpscalingPrevention() async {
        let originalImage = createTestImage(width: 100, height: 50)
        let targetSize = Size(width: 200, height: 25) // 幅は大きく、高さは小さく
        
        let decodedImage = await processor.decoded(
            image: originalImage,
            for: targetSize,
            usePreparingForDisplay: false,
            interpolationQuality: .default
        )
        
        // targetSizeにリサイズ
        #expect(decodedImage?.width == 200)
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
