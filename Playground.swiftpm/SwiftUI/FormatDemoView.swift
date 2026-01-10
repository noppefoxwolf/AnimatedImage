import AnimatedImage
import SwiftUI

struct FormatDemoView: View {
    var body: some View {
        VStack {
            HStack {
                VStack {
                    let url = Bundle.main.url(forResource: "elephant", withExtension: "png")!
                    let animatedImage = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                    AnimatedImagePlayer(animatedImage: animatedImage)
                        .frame(width: 100, height: 100)
                    Text("APNG")
                }
                VStack {
                    let url = Bundle.main.url(
                        forResource: "animated-webp-supported",
                        withExtension: "webp"
                    )!
                    let animatedImage = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                    AnimatedImagePlayer(animatedImage: animatedImage)
                        .frame(width: 100, height: 100)
                    Text("WebP")
                }
                VStack {
                    let url = Bundle.main.url(forResource: "1342-splash", withExtension: "gif")!
                    let animatedImage = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                    AnimatedImagePlayer(animatedImage: animatedImage)
                        .frame(width: 100, height: 100)
                    Text("GIF")
                }
            }
            HStack {
                VStack {
                    let url = Bundle.main.url(forResource: "single-frame", withExtension: "png")!
                    let animatedImage = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                    AnimatedImagePlayer(animatedImage: animatedImage)
                        .frame(width: 100, height: 100)
                    Text("PNG")
                }
                VStack {
                    let url = Bundle.main.url(
                        forResource: "b848520ba07a354c",
                        withExtension: "png"
                    )!
                    let animatedImage = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                    AnimatedImagePlayer(animatedImage: animatedImage)
                        .frame(width: 100, height: 100)
                    Text("PNG(Gray)")
                }
                Spacer()
            }
        }
    }
}
