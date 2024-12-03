import UIKit

public final class BackportUpdateLink: UpdateLink, DisplayLinkTarget {
    private var displayLink: CADisplayLink!
    
    public init(view: UIView) {
        displayLink = CADisplayLink(
            target: DisplayLinkProxy(target: self),
            selector: #selector(DisplayLinkProxy<Self>.updateContents)
        )
    }
    
    public var isEnabled: Bool {
        get { !displayLink.isPaused }
        set { displayLink.isPaused = !newValue }
    }
    
    public var requiresContinuousUpdates: Bool = false {
        didSet {
            if requiresContinuousUpdates {
                displayLink.add(to: .main, forMode: .common)
            } else {
                displayLink.remove(from: .main, forMode: .common)
            }
        }
    }
    
    public var preferredFrameRateRange: CAFrameRateRange {
        get { displayLink?.preferredFrameRateRange ?? .default }
        set { displayLink?.preferredFrameRateRange = newValue }
    }
    
    private var handlers: [(any UpdateLink, any UpdateInfo) -> Void] = []
    public func addAction(
        handler: @escaping (any UpdateLink, any UpdateInfo) -> Void
    ) {
        handlers.append(handler)
    }
    
    func updateContents(_ displayLink: CADisplayLink) {
        let info = BackportUpdateInfo(modelTime: displayLink.targetTimestamp)
        handlers.forEach { action in
            action(self, info)
        }
    }
}

final class BackportUpdateInfo: UpdateInfo {
    var modelTime: TimeInterval
    
    init(modelTime: TimeInterval) {
        self.modelTime = modelTime
    }
}
