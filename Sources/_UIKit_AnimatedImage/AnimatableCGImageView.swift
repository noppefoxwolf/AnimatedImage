public import UIKit
import UpdateLink

open class AnimatableCGImageView: CGImageView {
    lazy var updateLink: (any UpdateLink) = { preconditionFailure() }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        if #available(iOS 18.0, visionOS 2.0, *), Self.isSupportedUIUpdateLink {
            updateLink = UIUpdateLink(view: self)
        } else {
            updateLink = BackportUpdateLink(view: self)
        }
        updateLink.preferredFrameRateRange = CAFrameRateRange(
            minimum: 1,
            maximum: 60
        )
        updateLink.addAction(handler: { [unowned self] _, info in
            updateContents(for: info.modelTime)
        })
        updateLink.requiresContinuousUpdates = true
        updateLink.isEnabled = true
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static var isSupportedUIUpdateLink: Bool {
        if #available(iOS 18.0, visionOS 2.0, *) {
            // workaround: Designed for iPad doesn't have UIUpdateLink.
            if ProcessInfo.processInfo.isiOSAppOnMac {
                false
            } else {
                true
            }
        } else {
            false
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if !Self.isSupportedUIUpdateLink {
            updateLink.isEnabled = true
        }
    }

    open override func removeFromSuperview() {
        super.removeFromSuperview()
        if !Self.isSupportedUIUpdateLink {
            updateLink.isEnabled = false
        }
    }

    open func updateContents(for targetTimestamp: TimeInterval) {
    }
}
