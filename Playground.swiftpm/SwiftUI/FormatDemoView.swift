import AnimatedImage
import SwiftUI

struct FormatDemoView: View {
    private struct DemoItem: Identifiable {
        let id = UUID()
        let title: String
        let resource: String
        let fileExtension: String
    }

    private struct DemoCell: View {
        let item: DemoItem

        var body: some View {
            let url = Bundle.main.url(
                forResource: item.resource,
                withExtension: item.fileExtension
            )!
            let image = try! AnimatedImage(contentsOf: url, withConfiguration: .default)

            VStack(spacing: 8) {
                AnimatedImagePlayer(image: image)
                    .frame(width: 100, height: 100)
                Text(item.title)
                    .font(.caption)
            }
        }
    }

    private let items: [DemoItem] = [
        DemoItem(title: "APNG", resource: "elephant", fileExtension: "png"),
        DemoItem(title: "WebP", resource: "animated-webp-supported", fileExtension: "webp"),
        DemoItem(title: "GIF", resource: "1342-splash", fileExtension: "gif"),
        DemoItem(title: "PNG", resource: "single-frame", fileExtension: "png"),
        DemoItem(title: "PNG(Gray)", resource: "b848520ba07a354c", fileExtension: "png"),
    ]

    private let columns: [GridItem] = [
        GridItem(.fixed(120), spacing: 16),
        GridItem(.fixed(120), spacing: 16),
        GridItem(.fixed(120), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(items) { item in
                    DemoCell(item: item)
                }
            }
            .padding(16)
        }
    }
}
