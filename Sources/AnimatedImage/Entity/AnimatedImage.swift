import Foundation
public import CoreGraphics

public protocol AnimatedImage: Sendable {
    var name: String { get }
    func makeImageCount() -> Int
    func makeDelayTime(at index: Int) -> Double
    func makeImage(at index: Int) -> CGImage?
}
