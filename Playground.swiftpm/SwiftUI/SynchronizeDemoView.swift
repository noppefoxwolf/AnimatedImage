import AnimatedImage
import SwiftUI

struct SynchronizeDemoView: View {
    @State var image1: AnimatedImage? = nil
    @State var image2: AnimatedImage? = nil

    var body: some View {
        HStack {
            VStack {
                if let image1 {
                    AnimatedImagePlayer(animatedImage: image1)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                }
                Button {
                    let url = Bundle.main.url(forResource: "7896-blob-jam", withExtension: "gif")!
                    image1 = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                } label: {
                    Text("Load 1")
                }
                .disabled(image1 != nil)
            }
            VStack {
                if let image2 {
                    AnimatedImagePlayer(animatedImage: image2)
                        .frame(width: 100, height: 100)
                        .background(Color.gray)
                }
                Button {
                    let url = Bundle.main.url(forResource: "7896-blob-jam", withExtension: "gif")!
                    image2 = try! AnimatedImage(contentsOf: url, withConfiguration: .default)
                } label: {
                    Text("Load 2")
                }
                .disabled(image2 != nil)
            }
        }
    }
}
