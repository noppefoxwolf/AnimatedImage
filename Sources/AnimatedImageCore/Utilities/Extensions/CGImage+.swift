import QuartzCore

extension CGImage {
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    nonisolated func decoded(
        for size: CGSize,
        usePreparingForDisplay: Bool = true,
        scale: CGFloat,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let newSize = aspectFitSize(
            for: self.size,
            maxSize: size
        ).applying(CGAffineTransform(scaleX: scale, y: scale))
        if self.size.isLessThanOrEqualTo(newSize) && usePreparingForDisplay {
            return self
        }
        return resize(image: self, newSize: newSize, interpolationQuality: interpolationQuality)
    }
    
    nonisolated func aspectFitSize(for currentSize: CGSize, maxSize: CGSize) -> CGSize {
        let aspectWidth = maxSize.width / currentSize.width
        let aspectHeight = maxSize.height / currentSize.height
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
    nonisolated func resize(
        image: CGImage,
        newSize: CGSize,
        interpolationQuality: CGInterpolationQuality
    ) -> CGImage? {
        let width = Int(newSize.width)
        let height = Int(newSize.height)
        
        guard width > 0 && height > 0 else { return nil }
        
        let colorSpace = image.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return nil }
        
        context.interpolationQuality = interpolationQuality
        context.draw(image, in: CGRect(origin: .zero, size: newSize))
        
        return context.makeImage()
    }
}

extension CGSize {
    func isLessThanOrEqualTo(_ size: CGSize) -> Bool {
        width <= size.width && height <= size.height
    }
}
