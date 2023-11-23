import ImageIO

extension CGImageSource {
    func makeImage(at index: Int) -> CGImage? {
        CGImageSourceCreateImageAtIndex(self, index, nil)
    }
    
    func makeImageCount() -> Int {
        CGImageSourceGetCount(self)
    }
    
    func apngMakeDelayTime(at index: Int) -> Double {
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [CFString : Any]
        let frameProperty = imageProperty?[kCGImagePropertyPNGDictionary] as? [CFString : Any]
        let delayTime = frameProperty?[kCGImagePropertyAPNGDelayTime] as? Double
        return delayTime ?? 0.1
    }
    
    func gifmakeDelayTime(at index: Int) -> Double {
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [CFString : Any]
        let frameProperty = imageProperty?[kCGImagePropertyGIFDictionary] as? [CFString : Any]
        let delayTime = frameProperty?[kCGImagePropertyGIFDelayTime] as? Double
        return delayTime ?? 0.1
    }
    
    func webpMakeDelayTime(at index: Int) -> Double {
        let imageProperty = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [CFString : Any]
        let frameProperty = imageProperty?[kCGImagePropertyWebPDictionary] as? [CFString : Any]
        let delayTime = frameProperty?[kCGImagePropertyWebPDelayTime] as? Double
        return delayTime ?? 0.1
    }
}
