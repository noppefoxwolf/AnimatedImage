import Foundation
public import CoreGraphics

public protocol AnimatedImage: Sendable {
    var name: String { get }
    var imageCount: Int { get }
    func delayTime(at index: Int) -> Double
    func image(at index: Int) -> CGImage?
}
