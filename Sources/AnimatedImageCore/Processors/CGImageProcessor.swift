public import QuartzCore

public actor CGImageProcessor: Sendable {

    public init() {}

    public func decoded(
        image: CGImage,
        for size: Size,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let originalSize = Size(width: image.width, height: image.height)
        return resize(image: image, newSize: size, interpolationQuality: interpolationQuality)
    }

    func resize(
        image: CGImage,
        newSize: Size,
        interpolationQuality: CGInterpolationQuality
    ) -> CGImage? {
        let width = newSize.width
        let height = newSize.height

        guard width > 0 && height > 0 else { return nil }

        // TOOD: image.colorSpaceがグレーの場合はCGColorSpaceCreateDeviceGray()を使いたい
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Little, CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]

        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        )
        
        guard let context else { fatalError() }

        context.interpolationQuality = interpolationQuality
        context.draw(image, in: CGRect(origin: .zero, size: newSize.cgSize))

        return context.makeImage()
    }
}
