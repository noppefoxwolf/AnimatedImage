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
        uiView.image = image
        uiView.startAnimating()
    }
    
    public static func dismantleUIView(_ uiView: AnimatedImageView, coordinator: ()) {
        uiView.stopAnimating()
        uiView.image = nil
    }
}
