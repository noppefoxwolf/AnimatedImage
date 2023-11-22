import Foundation
import ImageIO

open class GifImage: SequencialImage {
    public let name: String
    let data: Data
    
    public init(name: String = UUID().uuidString, data: Data) {
        self.name = name
        self.data = data
    }
    
    public nonisolated var imageCount: Int {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.imageCount ?? 0
    }
    
    public nonisolated func delayTime(at index: Int) -> Double {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.gifDelayTime(at: index) ?? 0.1
    }
    
    public nonisolated func image(at index: Int) -> CGImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.image(at: index)
    }
}

