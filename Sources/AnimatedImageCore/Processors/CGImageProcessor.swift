import QuartzCore

public actor CGImageProcessor: Sendable {
    
    public init() {}
    
    public func decoded(
        image: CGImage,
        for size: Size,
        usePreparingForDisplay: Bool = true,
        scale: CGFloat,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let originalSize = Size(width: image.width, height: image.height)
        let constrainedSize = Size(
            width: min(size.width, originalSize.width),
            height: min(size.height, originalSize.height)
        )
        
        let newSize = aspectFitSize(
            of: originalSize,
            in: constrainedSize
        )
        .applying(CGAffineTransform(scaleX: scale, y: scale))
        
        if originalSize.isLessThanOrEqual(to: newSize) && usePreparingForDisplay {
            return image
        }
        return resize(image: image, newSize: newSize, interpolationQuality: interpolationQuality)
    }
    
    func aspectFitSize(of currentSize: Size, in maxSize: Size) -> Size {
        let aspectWidth = CGFloat(maxSize.width) / CGFloat(currentSize.width)
        let aspectHeight = CGFloat(maxSize.height) / CGFloat(currentSize.height)
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
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
