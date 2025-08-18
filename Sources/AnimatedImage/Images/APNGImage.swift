public import Foundation
import ImageIO
import CoreGraphics

public final class APNGImage: AnimatedImage, Sendable {
    public let name: String
    let data: Data
    
    public init(name: String = UUID().uuidString, data: Data) {
        self.name = name
        self.data = data
    }
    
    public nonisolated func makeImageCount() -> Int {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.makeImageCount() ?? 0
    }
    
    public nonisolated func makeDelayTime(at index: Int) -> Double {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.makeAPNGDelayTime(at: index) ?? 0.1
    }
    
    public nonisolated func makeImage(at index: Int) -> CGImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.makeImage(at: index)
    }
}

