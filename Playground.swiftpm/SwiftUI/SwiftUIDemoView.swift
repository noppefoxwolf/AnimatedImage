
import SwiftUI
import AnimatedImageSwiftUI
import AnimatedImage

struct SwiftUIDemoView: View {
    let items: [AnimatedImageResourceItem]
    
    init() {
        let dataSource = (0..<100).reduce(into: [], { result, _ in
            result += AnimatedImageResource.examples
        })
        self.items = dataSource.map(AnimatedImageResourceItem.init(rawValue:))
        print(self.items.count)
    }
    
    var body: some View {
        let layout = [
            GridItem(.adaptive(minimum: 200, maximum: 200)),
        ]
        
        ScrollView {
            LazyVGrid(columns: layout) {
                ForEach(items) { item in
                    switch item.rawValue {
                    case .apng(let name):
                        let url = Bundle.main.url(forResource: name, withExtension: "png")!
                        let data = try! Data(contentsOf: url)
                        let image = APNGImage(name: name, data: data)
                        AnimatedImagePlayer(image: image)
                            .scaledToFill()
                    case .gif(let name):
                        let url = Bundle.main.url(forResource: name, withExtension: "gif")!
                        let data = try! Data(contentsOf: url)
                        let image = GifImage(name: name, data: data)
                        AnimatedImagePlayer(image: image)
                            .scaledToFill()
                    case .webp(let name):
                        let url = Bundle.main.url(forResource: name, withExtension: "webp")!
                        let data = try! Data(contentsOf: url)
                        let image = WebPImage(name: name, data: data)
                        AnimatedImagePlayer(image: image)
                            .scaledToFill()
                    }
                }
            }
        }
    }
}

