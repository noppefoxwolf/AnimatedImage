
import SwiftUI
import AnimatedImage

struct SwiftUIDemoView: View {
    let items: [AnimatedImageResourceItem]
    
    init() {
        //let dataSource = [AnimatedImageResource.examples[0]]
        let dataSource = (0..<50).reduce(into: [], { result, _ in
            result += AnimatedImageResource.examples
        })
        self.items = dataSource.map(AnimatedImageResourceItem.init(rawValue:))
        print(self.items.count)
    }
    
    var animatedImageViewConfiguration: AnimatedImageViewConfiguration {
        let configuration = AnimatedImageViewConfiguration.performance
        return configuration
    }
    
    var body: some View {
        let layout = [
            GridItem(.adaptive(minimum: 60, maximum: 60)),
        ]
        
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(items) { item in
                    AnimatedImagePlayer(image: image(for: item))
                        .scaledToFill()
                        .background(Color.gray)
                }
            }
        }.environment(\.animatedImageViewConfiguration, animatedImageViewConfiguration)
    }
    
    func image(for item: AnimatedImageResourceItem) -> any AnimatedImage {
        let image: any AnimatedImage
        switch item.rawValue {
        case .apng(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "png")!
            let data = try! Data(contentsOf: url)
            image = APNGImage(name: name, data: data)
        case .gif(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            image = GifImage(name: name, data: data)
        case .webp(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "webp")!
            let data = try! Data(contentsOf: url)
            image = WebPImage(name: name, data: data)
        }
        return image
    }
}
