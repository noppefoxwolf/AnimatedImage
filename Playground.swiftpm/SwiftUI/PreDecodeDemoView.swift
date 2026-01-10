import AnimatedImage
import SwiftUI

struct PreDecodeDemoView: View {
    private struct DemoColumn: View {
        let title: String
        let image: AnimatedImage
        let size: CGSize
        let status: String?

        var body: some View {
            VStack(spacing: 8) {
                AnimatedImagePlayer(image: image)
                    .frame(width: size.width, height: size.height)
                    .background(Color.gray.opacity(0.2))
                Text(title)
                    .font(.caption)
                if let status {
                    Text(status)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @Environment(\.displayScale) private var displayScale
    @State private var decodedImage: AnimatedImage? = nil
    @State private var isDecoding = false
    @State private var isPlaying = false

    private let image: AnimatedImage = {
        let url = Bundle.main.url(forResource: "1342-splash", withExtension: "gif")!
        return try! AnimatedImage(contentsOf: url, withConfiguration: .default)
    }()

    var body: some View {
        let layoutSize = CGSize(width: 140, height: 140)

        VStack(spacing: 20) {
            VStack(spacing: 8) {
                if let decodedImage, isPlaying {
                    DemoColumn(
                        title: "Pre-decoded",
                        image: decodedImage,
                        size: layoutSize,
                        status: "Playing"
                    )
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: layoutSize.width, height: layoutSize.height)
                        Text(decodedImage == nil ? "Waiting" : "Ready")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Pre-decoded")
                        .font(.caption)
                    Text(decodedImage == nil ? "Not decoded" : "Decoded")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 12) {
                Button(isDecoding ? "Decoding..." : "Pre-decode") {
                    Task {
                        await preDecodeIfNeeded(size: layoutSize)
                    }
                }
                .disabled(isDecoding || decodedImage != nil)

                Button(isPlaying ? "Stop" : "Play") {
                    isPlaying.toggle()
                }
                .disabled(decodedImage == nil)
            }

            Text("Pre-decode warms the cache. Play uses the decoded image.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }

    @MainActor
    private func preDecodeIfNeeded(size: CGSize) async {
        guard decodedImage == nil, !isDecoding else { return }
        isDecoding = true
        let decoded = await AnimatedImageLoader.shared.decode(
            image,
            layout: (size: size, scale: displayScale)
        )
        decodedImage = decoded
        isPlaying = false
        isDecoding = false
    }
}
