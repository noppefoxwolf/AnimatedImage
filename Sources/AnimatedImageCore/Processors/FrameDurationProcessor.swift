
struct FrameDurationProcessor: Sendable {
    
    let defaultDelayTime: Double = 0.1
    let minimumDelayTime: Double = 0.011 // 10ms
    
    func process(
        unclampedDelayTime: () -> Double?,
        delayTime: () -> Double?
    ) -> Double {
        let result: Double
        if let unclampedDelayTime = unclampedDelayTime() {
            result = unclampedDelayTime
        } else if let delayTime = delayTime() {
            result = delayTime
        } else {
            result = defaultDelayTime
        }
        // http://webkit.org/b/36082
        if result < minimumDelayTime {
            return defaultDelayTime
        }
        return result
    }
}
