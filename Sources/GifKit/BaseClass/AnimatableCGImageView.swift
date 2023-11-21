import UIKit

open class AnimatableCGImageView: CGImageView {
    private var displayLink: CADisplayLink? = nil
    
    open func startAnimating() {
        stopAnimating()
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateContents)
        )
        displayLink?.add(to: .main, forMode: .common)
    }
    
    open func stopAnimating() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    @objc private func updateContents(_ displayLink: CADisplayLink) {
        willUpdateContents(&contents, for: displayLink.targetTimestamp)
    }
    
    open func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
        
    }
}
