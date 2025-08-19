import CoreGraphics
public import Foundation
import ImageIO

public final class APNGImage: AnimatedImage, Sendable {
    public let name: String
    let data: Data

    public init(name: String = UUID().uuidString, data: Data) {
        self.name = name
        self.data = data
    }

    public nonisolated var imageCount: Int {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return 0 }
        return CGImageSourceGetCount(source)
    }

    public nonisolated func delayTime(at index: Int) -> Double {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return 0.1 }
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
        let frameProperty = imageProperty?[kCGImagePropertyPNGDictionary] as? [CFString: Any]
        let delayTime = frameProperty?[kCGImagePropertyAPNGDelayTime] as? Double
        return delayTime ?? 0.1
    }

    public nonisolated func image(at index: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }
}
