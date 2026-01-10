#if canImport(_UIKit_AnimatedImage)
public import SwiftUI
public import AnimatedImageCore
public import _UIKit_AnimatedImage
import UIKit

public struct AnimatedImagePlayer: UIViewRepresentable {
    let animatedImage: AnimatedImage
    let contentMode: ContentMode

    public init(animatedImage: AnimatedImage, contentMode: ContentMode = .fit) {
        self.animatedImage = animatedImage
        self.contentMode = contentMode
    }

    public func makeUIView(context: Context) -> AnimatedImageView {
        AnimatedImageView(frame: .null)
    }

    public func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        uiView.animatedImage = animatedImage
        uiView.contentMode = contentMode.asUIKit()
        uiView.layer.magnificationFilter = .nearest
    }

    public static func dismantleUIView(_ uiView: AnimatedImageView, coordinator: ()) {
        uiView.animatedImage = nil
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
