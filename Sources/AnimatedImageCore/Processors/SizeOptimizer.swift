import Foundation
import QuartzCore

public struct SizeOptimizer: Sendable {
    public init() {}
    
    public func optimizedSize(
        for renderSize: Size,
        maxSize: Size,
        scale: CGFloat, 
        imageSize: Size, 
        imageCount: Int = 1,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double = 0.8
    ) -> Size {
        let effectiveMaxSize = min(maxSize, renderSize)
        let constrainedSize = Size(
            width: min(effectiveMaxSize.width, imageSize.width),
            height: min(effectiveMaxSize.height, imageSize.height)
        )
        let aspectOptimizedSize = aspectFitSize(of: imageSize, in: constrainedSize)
        let scaledSize = aspectOptimizedSize.applying(
            CGAffineTransform(scaleX: scale, y: scale)
        )
        let memoryAdjustedSize = adjustSizeForMemoryConstraints(
            scaledSize, 
            imageCount: imageCount,
            maxMemoryUsage: maxMemoryUsage,
            targetMemoryRatio: targetMemoryRatio
        )
        
        return memoryAdjustedSize
    }
    
    public func isValidRenderSize(_ renderSize: Size) -> Bool {
        !renderSize.isEmpty
    }
    
    private func aspectFitSize(of currentSize: Size, in maxSize: Size) -> Size {
        let aspectWidth = CGFloat(maxSize.width) / CGFloat(currentSize.width)
        let aspectHeight = CGFloat(maxSize.height) / CGFloat(currentSize.height)
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
    private func adjustSizeForMemoryConstraints(
        _ size: Size, 
        imageCount: Int,
        maxMemoryUsage: Double,
        targetMemoryRatio: Double
    ) -> Size {
        let imageByteCount = size.width * size.height * 4
        let totalMemoryUsage = Double(imageByteCount * imageCount)
        let targetMemoryUsage = maxMemoryUsage * targetMemoryRatio
        
        if totalMemoryUsage <= targetMemoryUsage {
            return size
        }
        let reductionFactor = sqrt(targetMemoryUsage / totalMemoryUsage)
        let transform = CGAffineTransform(scaleX: reductionFactor, y: reductionFactor)
        return size.applying(transform)
    }
    
    public func integrityLevel(
        for imageSize: Size, 
        imageCount: Int,
        maxMemoryUsage: Double,
        maxLevelOfIntegrity: Double
    ) -> Double {
        let imageByteCount = imageSize.width * imageSize.height * 4
        let memoryPressure = Double(imageByteCount * imageCount) / maxMemoryUsage
        return min(1.0 / memoryPressure, maxLevelOfIntegrity)
    }
}