import UIKit

@MainActor
public protocol UpdateLink: AnyObject {
    var isEnabled: Bool { get set }
    var requiresContinuousUpdates: Bool { get set }
    var preferredFrameRateRange: CAFrameRateRange { get set }
    func addAction(handler: @escaping (any UpdateLink, any UpdateInfo) -> Void)
}

@MainActor
public protocol UpdateInfo: AnyObject {
    var modelTime: TimeInterval { get }
}

