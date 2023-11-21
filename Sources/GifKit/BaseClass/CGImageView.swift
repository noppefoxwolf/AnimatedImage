import UIKit

open class CGImageView: UIView {
    public var contents: CGImage? = nil {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    open override func display(_ layer: CALayer) {
        layer.contents = contents
        layer.contentsGravity = .resizeAspect
    }
}
