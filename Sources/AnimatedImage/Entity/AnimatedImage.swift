import Foundation
import CoreGraphics

public protocol AnimatedImage {
    var name: String { get }
    var imageCount: Int { get }
    func delayTime(at index: Int) -> Double
    func image(at index: Int) -> CGImage?
}
