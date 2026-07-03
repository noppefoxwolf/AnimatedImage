import AnimatedImage
import SwiftUI

struct ImageReplacementReproView: View {
    private enum Selection: String, CaseIterable, Identifiable {
        case first = "First"
        case second = "Second"

        var id: Self { self }
    }

    @Environment(\.displayScale) private var displayScale
    @State private var images: [Selection: AnimatedImage] = [:]
    @State private var selection: Selection = .first
    @State private var isPreparing = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Color.gray.opacity(0.2)

                if let image = images[selection] {
                    AnimatedImagePlayer(image: image)
                        .adjustAnimatedImageForSize(false)
                        .scaledToFit()
                        .frame(width: 180, height: 180)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 220, height: 220)

            Picker("Image", selection: $selection) {
                ForEach(Selection.allCases) { selection in
                    Text(selection.rawValue).tag(selection)
                }
            }
            .pickerStyle(.segmented)
            .disabled(images.count != Selection.allCases.count)

            Button("Switch Image") {
                selection = selection == .first ? .second : .first
            }
            .buttonStyle(.borderedProminent)
            .disabled(images.count != Selection.allCases.count)

            VStack(alignment: .leading, spacing: 8) {
                Text("Reproduction steps")
                    .font(.headline)
                Text("1. Wait until the first image appears.")
                Text("2. Tap Switch Image.")
                Text("Expected: the selected image remains visible.")
                Text("Actual before the fix: the view can become blank because the frame index is not reset.")
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(24)
        .navigationTitle("Image Replacement Repro")
        .task {
            await prepareImagesIfNeeded()
        }
    }

    @MainActor
    private func prepareImagesIfNeeded() async {
        guard images.isEmpty, !isPreparing else { return }
        isPreparing = true

        let first = makeImage(resource: "single-frame", extension: "png")
        let second = makeImage(resource: "5763-blobthanks", extension: "png")
        let layout = (size: CGSize(width: 180, height: 180), scale: displayScale)

        async let decodedFirst = AnimatedImageLoader.shared.decode(first, layout: layout)
        async let decodedSecond = AnimatedImageLoader.shared.decode(second, layout: layout)

        images = [
            .first: await decodedFirst,
            .second: await decodedSecond,
        ]
        selection = .first
        isPreparing = false
    }

    private func makeImage(resource: String, extension pathExtension: String) -> AnimatedImage {
        let url = Bundle.main.url(forResource: resource, withExtension: pathExtension)!
        return try! AnimatedImage(contentsOf: url, withConfiguration: .default)
    }
}
