import Foundation
import QuartzCore
import CoreGraphics

public struct AnimatedImageViewConfiguration: Sendable {
    public static var unlimited: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: .max,
            maxSize: CGSize(width: Double.infinity, height: Double.infinity),
            maxLevelOfIntegrity: 1,
            interpolationQuality: .high,
            contentsFilter: .trilinear,
            taskPriority: .userInitiated
        )
    }
    
    public static var `default`: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: 1 * 1024 * 1024, // 1MB
            maxSize: CGSize(width: 128, height: 128),
            maxLevelOfIntegrity: 0.8,
            interpolationQuality: .default,
            contentsFilter: .linear,
            taskPriority: .medium
        )
    }
    
    public static var performance: AnimatedImageViewConfiguration {
        AnimatedImageViewConfiguration(
            maxByteCount: 1 * 1024 * 1024 / 50, // 20KB
            maxSize: CGSize(width: 32, height: 32),
            maxLevelOfIntegrity: 0.25,
            interpolationQuality: .none,
            contentsFilter: .nearest,
            taskPriority: .low
        )
    }
    
    public var maxByteCount: Int64
    public var maxSize: CGSize
    public var maxLevelOfIntegrity: Double
    public var interpolationQuality: CGInterpolationQuality
    public var contentsFilter: CALayerContentsFilter
    public var taskPriority: TaskPriority
}
