import ImageIO

extension CGImageSource {
    func image(at index: Int) -> CGImage? {
        CGImageSourceCreateImageAtIndex(self, index, nil)
    }
    
    var imageCount: Int {
        CGImageSourceGetCount(self)
    }
    
    func gifDelayTime(at index: Int) -> Double {
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [CFString : Any]
        let frameProperty = imageProperty?[kCGImagePropertyGIFDictionary] as? [CFString : Any]
        let delayTime = frameProperty?[kCGImagePropertyGIFDelayTime] as? Double
        return delayTime ?? 0.1
    }
}
