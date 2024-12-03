import UIKit

@available(iOS 18.0, visionOS 2.0, *)
extension UIUpdateInfo: UpdateInfo {}

@available(iOS 18.0, visionOS 2.0, *)
extension UIUpdateLink: UpdateLink {
    public func addAction(
        handler: @escaping (any UpdateLink, any UpdateInfo) -> Void
    ) {
        addAction { (link: UIUpdateLink, info: UIUpdateInfo) in
            handler(link, info)
        }
    }
}
