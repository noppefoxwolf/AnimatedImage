import UIKit

extension UIImage {
    nonisolated func decoded(for size: CGSize, usePreparingForDisplay: Bool = false) async -> UIImage? {
        let newSize = aspectFitSize(for: self.size, maxSize: size)
        if newSize == self.size && usePreparingForDisplay {
            return await self.byPreparingForDisplay()
        }
        return resize(image: self, newSize: newSize)
    }
    
    nonisolated func aspectFitSize(for currentSize: CGSize, maxSize: CGSize) -> CGSize {
        let aspectWidth = maxSize.width / currentSize.width
        let aspectHeight = maxSize.height / currentSize.height
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
    nonisolated func resize(image: UIImage, newSize: CGSize) -> UIImage? {
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        let renderer = UIGraphicsImageRenderer(size: newSize, format: rendererFormat)
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
