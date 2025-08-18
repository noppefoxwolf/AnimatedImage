import QuartzCore

public protocol DisplayLinkTarget: AnyObject {
    @MainActor
    func updateContents(_ displayLink: CADisplayLink)
}

public final class DisplayLinkProxy<T: DisplayLinkTarget> {
    private weak var target: T?
    public init(target: T) { self.target = target }

    @MainActor
    @objc public func updateContents(_ displayLink: CADisplayLink) {
        target?.updateContents(displayLink)
    }
}
