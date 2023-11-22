import QuartzCore

protocol DisplayLinkTarget: AnyObject {
    func updateContents(_ displayLink: CADisplayLink)
}

final class DisplayLinkProxy<T: DisplayLinkTarget> {
    private weak var target: T?
    init(target: T) { self.target = target }

    @objc func updateContents(_ displayLink: CADisplayLink) {
        target?.updateContents(displayLink)
    }
}
