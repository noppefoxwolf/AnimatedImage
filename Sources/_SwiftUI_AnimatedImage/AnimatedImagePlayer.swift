#if canImport(_UIKit_AnimatedImage)
public import SwiftUI
public import AnimatedImageCore
public import _UIKit_AnimatedImage
import UIKit

public struct AnimatedImagePlayer: UIViewRepresentable {
    let imageSource: any AnimatedImageSource
    let contentMode: ContentMode

    public init(imageSource: any AnimatedImageSource, contentMode: ContentMode = .fit) {
        self.imageSource = imageSource
        self.contentMode = contentMode
    }

    public func makeUIView(context: Context) -> AnimatedImageView {
        AnimatedImageView(frame: .null)
    }

    public func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        uiView.animatedImage = AnimatedImage(
            imageSource: imageSource,
            withConfiguration: context.environment.animatedImageConfiguration
        )
        uiView.contentMode = contentMode.asUIKit()
        uiView.startAnimating()
    }

    public static func dismantleUIView(_ uiView: AnimatedImageView, coordinator: ()) {
        uiView.stopAnimating()
        uiView.animatedImage = nil
    }
}

private struct AnimatedImageConfigurationKey: EnvironmentKey {
    static var defaultValue: AnimatedImage.Configuration { .default }
}

extension EnvironmentValues {
    @MainActor
    public var animatedImageConfiguration: AnimatedImage.Configuration {
        get { self[AnimatedImageConfigurationKey.self] }
        set { self[AnimatedImageConfigurationKey.self] = newValue }
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
