#if canImport(UIKit)
import Testing
import UIKit
@testable import AnimatedImage

@Suite("ContentMode変換テスト")
struct ContentModeTests {

    @Test("UIView.ContentModeからCALayerContentsGravityへの変換")
    func contentModeToContentsGravity() {
        #expect(UIView.ContentMode.scaleToFill.contentsGravity == .resize)
        #expect(UIView.ContentMode.scaleAspectFit.contentsGravity == .resizeAspect)
        #expect(UIView.ContentMode.scaleAspectFill.contentsGravity == .resizeAspectFill)
        #expect(UIView.ContentMode.redraw.contentsGravity == .resize)
        #expect(UIView.ContentMode.center.contentsGravity == .center)
        #expect(UIView.ContentMode.top.contentsGravity == .top)
        #expect(UIView.ContentMode.bottom.contentsGravity == .bottom)
        #expect(UIView.ContentMode.left.contentsGravity == .left)
        #expect(UIView.ContentMode.right.contentsGravity == .right)
        #expect(UIView.ContentMode.topLeft.contentsGravity == .topLeft)
        #expect(UIView.ContentMode.topRight.contentsGravity == .topRight)
        #expect(UIView.ContentMode.bottomLeft.contentsGravity == .bottomLeft)
        #expect(UIView.ContentMode.bottomRight.contentsGravity == .bottomRight)
    }

    @Test("CALayerContentsGravityからUIView.ContentModeへの変換")
    func contentsGravityToContentMode() {
        #expect(CALayerContentsGravity.resize.contentMode == .scaleToFill)
        #expect(CALayerContentsGravity.resizeAspect.contentMode == .scaleAspectFit)
        #expect(CALayerContentsGravity.resizeAspectFill.contentMode == .scaleAspectFill)
        #expect(CALayerContentsGravity.center.contentMode == .center)
        #expect(CALayerContentsGravity.top.contentMode == .top)
        #expect(CALayerContentsGravity.bottom.contentMode == .bottom)
        #expect(CALayerContentsGravity.left.contentMode == .left)
        #expect(CALayerContentsGravity.right.contentMode == .right)
        #expect(CALayerContentsGravity.topLeft.contentMode == .topLeft)
        #expect(CALayerContentsGravity.topRight.contentMode == .topRight)
        #expect(CALayerContentsGravity.bottomLeft.contentMode == .bottomLeft)
        #expect(CALayerContentsGravity.bottomRight.contentMode == .bottomRight)
    }

    @Test("往復変換の一貫性")
    func roundTripConsistency() {
        let contentModes: [UIView.ContentMode] = [
            .scaleToFill, .scaleAspectFit, .scaleAspectFill,
            .center, .top, .bottom, .left, .right,
            .topLeft, .topRight, .bottomLeft, .bottomRight,
        ]

        for contentMode in contentModes {
            let contentsGravity = contentMode.contentsGravity
            let convertedBack = contentsGravity.contentMode

            // redrawは特別扱い（resizeに変換される）
            if contentMode == .redraw {
                #expect(convertedBack == .scaleToFill)
            } else {
                #expect(convertedBack == contentMode)
            }
        }
    }

    @Test("CGImageViewでのcontentMode使用")
    @MainActor
    func cgImageViewContentMode() {
        let imageView = CGImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))

        imageView.contentMode = .scaleAspectFit
        #expect(imageView.layer.contentsGravity == .resizeAspect)

        imageView.contentMode = .scaleAspectFill
        #expect(imageView.layer.contentsGravity == .resizeAspectFill)

        imageView.contentMode = .center
        #expect(imageView.layer.contentsGravity == .center)

        imageView.contentMode = .topLeft
        #expect(imageView.layer.contentsGravity == .topLeft)
    }
}
#endif
