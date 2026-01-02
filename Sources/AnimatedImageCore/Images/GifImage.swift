public import CoreGraphics
public import Foundation
import ImageIO

public final class GifImage: AnimatedImage, Sendable {
    public let name: String
    let data: Data

    public init(name: String = UUID().uuidString, data: Data) {
        self.name = name
        self.data = data
    }

    @concurrent
    public var imageCount: Int {
        get async {
            guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return 0 }
            return CGImageSourceGetCount(source)
        }
    }
    
    @concurrent
    public func delayTime(at index: Int) async -> Double {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return 0.1 }
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any]
        let frameProperty = imageProperty?[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        let frameDurationProcessor = FrameDurationProcessor()
        let delayTime = await frameDurationProcessor.process(
            unclampedDelayTime: { frameProperty?[kCGImagePropertyGIFUnclampedDelayTime] as? Double },
            delayTime: { frameProperty?[kCGImagePropertyGIFDelayTime] as? Double }
        )
        return delayTime
    }

    @concurrent
    public func image(at index: Int) async -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }
}
