public import CoreGraphics
import Foundation

public protocol AnimatedImage: Sendable {
    var name: String { get }
    var imageCount: Int { get async }
    func delayTime(at index: Int) async -> Double
    func image(at index: Int) async -> CGImage?
}
