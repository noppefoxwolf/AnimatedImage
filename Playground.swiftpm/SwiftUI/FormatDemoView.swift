import SwiftUI
import AnimatedImage

struct FormatDemoView: View {
    var body: some View {
        HStack {
            VStack {
                let url = Bundle.main.url(forResource: "elephant", withExtension: "png")!
                let data = try! Data(contentsOf: url)
                let image = APNGImage(data: data)
                AnimatedImagePlayer(image: image)
                    .frame(width: 100, height: 100)
                Text("APNG")
            }
            VStack {
                let url = Bundle.main.url(forResource: "animated-webp-supported", withExtension: "webp")!
                let data = try! Data(contentsOf: url)
                let image = WebPImage(data: data)
                AnimatedImagePlayer(image: image)
                    .frame(width: 100, height: 100)
                Text("WebP")
            }
            VStack {
                let url = Bundle.main.url(forResource: "1342-splash", withExtension: "gif")!
                let data = try! Data(contentsOf: url)
                let image = GifImage(data: data)
                AnimatedImagePlayer(image: image)
                    .frame(width: 100, height: 100)
                Text("GIF")
            }
        }
    }
}
