public import UIKit

open class CGImageView: UIView {
    public var contents: CGImage? = nil {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        get { layer.contentsGravity.contentMode }
        set { layer.contentsGravity = newValue.contentsGravity }
    }
    
    open override func display(_ layer: CALayer) {
        layer.contents = contents
    }
}
