import AnimatedImage
import SwiftUI

struct SynchronizeDemoView: View {
    @State var image1: (any AnimatedImageSource)? = nil
    @State var image2: (any AnimatedImageSource)? = nil

    var body: some View {
        HStack {
            VStack {
                if let image1 {
                    AnimatedImagePlayer(imageSource: image1)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                }
                Button {
                    let url = Bundle.main.url(forResource: "7896-blob-jam", withExtension: "gif")!
                    let data = try! Data(contentsOf: url)
                    image1 = GifImageSource(data: data)
                } label: {
                    Text("Load 1")
                }
                .disabled(image1 != nil)
            }
            VStack {
                if let image2 {
                    AnimatedImagePlayer(imageSource: image2)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                }
                Button {
                    let url = Bundle.main.url(forResource: "7896-blob-jam", withExtension: "gif")!
                    let data = try! Data(contentsOf: url)
                    image2 = GifImageSource(data: data)
                } label: {
                    Text("Load 2")
                }
                .disabled(image2 != nil)
            }
        }
    }
}
