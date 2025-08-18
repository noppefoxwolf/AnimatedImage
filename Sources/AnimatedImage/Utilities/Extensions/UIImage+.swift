import UIKit

extension UIImage {
    nonisolated func decoded(for size: CGSize, usePreparingForDisplay: Bool = true, interpolationQuality: CGInterpolationQuality) async -> UIImage? {
        let newSize = aspectFitSize(for: self.size, maxSize: size)
        if self.size.isLessThanOrEqualTo(newSize) && usePreparingForDisplay {
            return await self.byPreparingForDisplay()
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
    
    nonisolated func resize(image: UIImage, newSize: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        let renderer = UIGraphicsImageRenderer(size: newSize, format: rendererFormat)
        return renderer.image { context in
            context.cgContext.interpolationQuality = interpolationQuality
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension CGSize {
    func isLessThanOrEqualTo(_ size: CGSize) -> Bool {
        width <= size.width && height <= size.height
    }
}
