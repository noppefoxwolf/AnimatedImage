public import UIKit
import UpdateLink

open class AnimatableCGImageView: CGImageView {
    var updateLink: (any UpdateLink)!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 18.0, *) {
            updateLink = UIUpdateLink(view: self)
        } else {
            updateLink = BackportUpdateLink(view: self)
        }
        updateLink.isEnabled = true
        updateLink.preferredFrameRateRange = CAFrameRateRange(
            minimum: 1,
            maximum: 60
        )
        updateLink.addAction(handler: { [unowned self] _, info in
            willUpdateContents(&contents, for: info.modelTime)
        })
        updateLink.requiresContinuousUpdates = true
    }
    
    @MainActor public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func startAnimating() {
        updateLink.isEnabled = true
    }
    
    open func stopAnimating() {
        updateLink.isEnabled = false
    }
    
    open func willUpdateContents(_ contents: inout CGImage?, for targetTimestamp: TimeInterval) {
    }
}

