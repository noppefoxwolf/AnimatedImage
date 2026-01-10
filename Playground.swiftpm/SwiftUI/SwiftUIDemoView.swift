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

    let animatedImageConfiguration: AnimatedImage.Configuration = .performance

    var body: some View {
        let layout = [
            GridItem(.adaptive(minimum: 60, maximum: 60))
        ]

        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(items) { item in
                    AnimatedImagePlayer(image: image(for: item))
                        .scaledToFill()
                        .background(Color.gray)
                }
            }
        }
    }

    func image(for item: AnimatedImageResourceItem) -> AnimatedImage {
        switch item.rawValue {
        case .apng(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "png")!
            return try! AnimatedImage(
                contentsOf: url,
                withConfiguration: animatedImageConfiguration
            )
        case .gif(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "gif")!
            return try! AnimatedImage(
                contentsOf: url,
                withConfiguration: animatedImageConfiguration
            )
        case .webp(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "webp")!
            return try! AnimatedImage(
                contentsOf: url,
                withConfiguration: animatedImageConfiguration
            )
        }
    }
}
