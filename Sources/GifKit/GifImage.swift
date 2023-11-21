import Foundation
import ImageIO

open class GifImage {
    let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public var imageCount: Int {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.imageCount ?? 0
    }
    
    public func delayTime(at index: Int) -> Double {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.gifDelayTime(at: index) ?? 0.1
    }
    
    public func image(at index: Int) -> CGImage? {
        let source = CGImageSourceCreateWithData(data as CFData, nil)
        return source?.image(at: index)
    }
}
