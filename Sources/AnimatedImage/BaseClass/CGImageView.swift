public import UIKit

open class CGImageView: UIView {
    public var contents: CGImage? = nil {
        didSet {
            layer.setNeedsDisplay()
        }
    }
    
    open override var contentMode: UIView.ContentMode {
        didSet {
            switch contentMode {
            case .scaleToFill:
                layer.contentsGravity = .resize
            case .scaleAspectFit:
                layer.contentsGravity = .resizeAspect
            case .scaleAspectFill:
                layer.contentsGravity = .resizeAspectFill
            case .redraw:
                break
            case .center:
                layer.contentsGravity = .center
            case .top:
                layer.contentsGravity = .top
            case .bottom:
                layer.contentsGravity = .bottom
            case .left:
                layer.contentsGravity = .left
            case .right:
                layer.contentsGravity = .right
            case .topLeft:
                layer.contentsGravity = .topLeft
            case .topRight:
                layer.contentsGravity = .topRight
            case .bottomLeft:
                layer.contentsGravity = .bottomLeft
            case .bottomRight:
                layer.contentsGravity = .bottomRight
            @unknown default:
                break
            }
        }
    }
    
    open override func display(_ layer: CALayer) {
        layer.contents = contents
    }
}
