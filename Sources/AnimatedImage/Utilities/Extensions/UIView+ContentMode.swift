import UIKit

extension UIView.ContentMode {
    /// UIView.ContentModeをCALayerContentsGravityに変換する
    public var contentsGravity: CALayerContentsGravity {
        switch self {
        case .scaleToFill:
            return .resize
        case .scaleAspectFit:
            return .resizeAspect
        case .scaleAspectFill:
            return .resizeAspectFill
        case .redraw:
            return .resize
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .left:
            return .left
        case .right:
            return .right
        case .topLeft:
            return .topLeft
        case .topRight:
            return .topRight
        case .bottomLeft:
            return .bottomLeft
        case .bottomRight:
            return .bottomRight
        @unknown default:
            return .resize
        }
    }
}

extension CALayerContentsGravity {
    /// CALayerContentsGravityをUIView.ContentModeに変換する
    public var contentMode: UIView.ContentMode {
        switch self {
        case .resize:
            return .scaleToFill
        case .resizeAspect:
            return .scaleAspectFit
        case .resizeAspectFill:
            return .scaleAspectFill
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .left:
            return .left
        case .right:
            return .right
        case .topLeft:
            return .topLeft
        case .topRight:
            return .topRight
        case .bottomLeft:
            return .bottomLeft
        case .bottomRight:
            return .bottomRight
        default:
            return .scaleToFill
        }
    }
}