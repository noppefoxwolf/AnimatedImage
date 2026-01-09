import AnimatedImage
import SwiftUI

struct SwiftUIDemoView: View {
    let items: [AnimatedImageResourceItem]

    init() {
        //let dataSource = [AnimatedImageResource.examples[0]]
        let dataSource = (0..<50)
            .reduce(
                into: [],
                { result, _ in
                    result += AnimatedImageResource.examples
                }
            )
        self.items = dataSource.map(AnimatedImageResourceItem.init(rawValue:))
    }

    let animatedImageConfiguration: AnimatedImageProviderConfiguration = .performance

    var body: some View {
        let layout = [
            GridItem(.adaptive(minimum: 60, maximum: 60))
        ]

        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(items) { item in
                    AnimatedImagePlayer(imageSource: image(for: item))
                        .scaledToFill()
                        .background(Color.gray)
                }
            }
        }
        .environment(\.animatedImageProviderConfiguration, animatedImageConfiguration)
    }

    func image(for item: AnimatedImageResourceItem) -> any AnimatedImageSource {
        let imageSource: any AnimatedImageSource
        switch item.rawValue {
        case .apng(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "png")!
            let data = try! Data(contentsOf: url)
            imageSource = APNGImageSource(name: name, data: data)
        case .gif(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            imageSource = GifImageSource(name: name, data: data)
        case .webp(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "webp")!
            let data = try! Data(contentsOf: url)
            imageSource = WebPImageSource(name: name, data: data)
        }
        return imageSource
    }
}
