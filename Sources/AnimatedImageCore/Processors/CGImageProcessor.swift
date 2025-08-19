import QuartzCore

public actor CGImageProcessor: Sendable {
    
    public init() {}
    
    public func decoded(
        image: CGImage,
        for size: Size,
        usePreparingForDisplay: Bool = true,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let originalSize = Size(width: image.width, height: image.height)
        
        // optimizedSizeで既にサイズ計算が完了しているため、簡単なチェックのみ
        if originalSize.isLessThanOrEqual(to: size) && usePreparingForDisplay {
            return image
        }
        return resize(image: image, newSize: size, interpolationQuality: interpolationQuality)
    }
    
    // この関数はImageProcessor.aspectFitSize()に移動されたため削除
    
    func resize(
        image: CGImage,
        newSize: Size,
        interpolationQuality: CGInterpolationQuality
    ) -> CGImage? {
        let width = newSize.width
        let height = newSize.height

        guard width > 0 && height > 0 else { return nil }

        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo =
            CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

        guard
            let context = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            )
        else { return nil }

        context.interpolationQuality = interpolationQuality
        context.draw(image, in: CGRect(origin: .zero, size: newSize.cgSize))

        return context.makeImage()
    }
}
