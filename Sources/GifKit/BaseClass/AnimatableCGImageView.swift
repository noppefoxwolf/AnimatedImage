import UIKit

open class AnimatableCGImageView: CGImageView, DisplayLinkTarget {
    private var displayLink: CADisplayLink? = nil
    
    open func startAnimating() {
        stopAnimating()
        displayLink = CADisplayLink(
            target: DisplayLinkProxy(target: self),
            selector: #selector(DisplayLinkProxy<Self>.updateContents)
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    open func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func updateContents(_ displayLink: CADisplayLink) {
        willUpdateContents(&contents, for: displayLink.targetTimestamp)
    }
    
    open func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        
    }
}
