#if canImport(_UIKit_AnimatedImage)
public import SwiftUI
public import AnimatedImageCore
public import _UIKit_AnimatedImage
import UIKit

public struct AnimatedImagePlayer: UIViewRepresentable {
    let image: AnimatedImage
    let contentMode: ContentMode

    public init(image: AnimatedImage, contentMode: ContentMode = .fit) {
        self.image = image
        self.contentMode = contentMode
    }

    public func makeUIView(context: Context) -> AnimatedImageView {
        AnimatedImageView(frame: .null)
    }

    public func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        uiView.image = image
        uiView.contentMode = contentMode.asUIKit()
        uiView.layer.magnificationFilter = .nearest
    }

    public static func dismantleUIView(_ uiView: AnimatedImageView, coordinator: ()) {
        uiView.image = nil
    }
}

extension ContentMode {
    func asUIKit() -> UIKit.UIView.ContentMode {
        switch self {
        case .fit:
            return .scaleAspectFit
        case .fill:
            return .scaleAspectFill
        }
    }
}
#endif
