import SwiftUI
import AnimatedImage

public struct AnimatedImagePlayer: UIViewRepresentable {
    let image: any AnimatedImage
    
    public init(image: any AnimatedImage) {
        self.image = image
    }
    
    public func makeUIView(context: Context) -> AnimatedImageView {
        AnimatedImageView(frame: .null)
    }
    
    public func updateUIView(_ uiView: AnimatedImageView, context: Context) {
        uiView.configuration = context.environment.animatedImageViewConfiguration
        uiView.image = image
        uiView.startAnimating()
    }
    
    public static func dismantleUIView(_ uiView: AnimatedImageView, coordinator: ()) {
        uiView.stopAnimating()
        uiView.image = nil
    }
}

private struct AnimatedImageConfigurationKey: EnvironmentKey {
    static let defaultValue: AnimatedImageViewConfiguration = .default
}

extension EnvironmentValues {
    @MainActor
    public var animatedImageViewConfiguration: AnimatedImageViewConfiguration {
        get { self[AnimatedImageConfigurationKey.self] }
        set { self[AnimatedImageConfigurationKey.self] = newValue }
    }
}
