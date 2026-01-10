import AnimatedImage
import SwiftUI

enum ImageFormat: String, CaseIterable {
    case gif = "GIF"
    case apng = "APNG"
    case webp = "WEBP"

    var fileName: String {
        switch self {
        case .gif:
            return "8996-blob"
        case .apng:
            return "elephant"
        case .webp:
            return "animated-webp-supported"
        }
    }

    var fileExtension: String {
        switch self {
        case .gif:
            return "gif"
        case .apng:
            return "png"
        case .webp:
            return "webp"
        }
    }
}

struct QualityDemoView: View {
    @State
    var configuration: AnimatedImage.Configuration = .qualityDemo

    @State
    var width: Double = 100

    @State
    var maxWidth: Double = 128

    @State
    var selectedFormat: ImageFormat = .apng

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Section {
                    AnimatedImagePlayer(image: currentImage)
                        .frame(width: width, height: width)
                        .background(Color.gray)
                }
                .frame(height: 200)

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Render Width")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(width))pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $width, in: 1...100)
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Width")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(maxWidth))pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $maxWidth, in: 1...128)
                                .onChange(of: maxWidth) { oldValue, newValue in
                                    configuration.maxSize = Size(
                                        width: Int(newValue),
                                        height: configuration.maxSize.height
                                    )
                                }
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Cache size")
                                    .font(.headline)
                                Spacer()
                                Text(
                                    String(
                                        format: "%.2f MB",
                                        configuration.maxMemoryUsage.converted(to: .bytes).value
                                            / (1 * 1024 * 1024)
                                    )
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            Slider(
                                value: Binding<Double>(
                                    get: {
                                        configuration.maxMemoryUsage.converted(to: .bytes).value
                                            / (3 * 1024 * 1024)
                                    },
                                    set: { newValue in
                                        configuration.maxMemoryUsage = .init(
                                            value: (3 * 1024 * 1024) * newValue,
                                            unit: .bytes
                                        )
                                    }
                                ),
                                in: 0.001...1
                            )
                        }
                    }

                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Integrity")
                                    .font(.headline)
                                Spacer()
                                Text(
                                    String(
                                        format: "%.1f%%",
                                        configuration.maxLevelOfIntegrity * 100
                                    )
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            Slider(value: $configuration.maxLevelOfIntegrity, in: 0.1...1)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 16) {
                    ForEach(ImageFormat.allCases, id: \.self) { format in
                        Button(format.rawValue) {
                            selectedFormat = format
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .tint(selectedFormat == format ? .primary : .secondary)
                    }
                }
            }
        }
        .onAppear {
            maxWidth = Double(configuration.maxSize.width)
        }
    }

    private var currentImage: AnimatedImage {
        let url = Bundle.main.url(
            forResource: selectedFormat.fileName,
            withExtension: selectedFormat.fileExtension
        )!
        return try! AnimatedImage(contentsOf: url, withConfiguration: configuration)
    }
}

extension AnimatedImage.Configuration {
    @MainActor
    public static var qualityDemo: Self {
        var configuration = Self.default
        configuration.maxMemoryUsage = .init(value: 1, unit: .megabits)
        //        configuration.taskPriority = .userInitiated
        return configuration
    }
}
