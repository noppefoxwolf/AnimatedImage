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
    var configuration: AnimatedImageProviderConfiguration = .qualityDemo

    @State
    var width: Double = 100
    
    @State
    var selectedFormat: ImageFormat = .apng

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Section {
                    AnimatedImagePlayer(image: currentImage)
                        .environment(\.animatedImageProviderConfiguration, configuration)
                        .frame(width: width, height: width)
                        .background(Color.gray)
                }
                .frame(height: 200)

                List {
                    Section {
                        Slider(value: $width, in: 1...100)
                    } header: {
                        Text("Render Width")
                    }

                    Section {
                        Slider(value: $configuration.maxSize.width, in: 1...32)
                    } header: {
                        Text("Max Width")
                    }

                    Section {
                        Slider(
                            value: Binding<Double>(
                                get: {
                                    configuration.maxMemoryUsage.converted(to: .bytes).value
                                        / (1 * 1024 * 1024)
                                },
                                set: { newValue in
                                    configuration.maxMemoryUsage = .init(
                                        value: (1 * 1024 * 1024) * newValue,
                                        unit: .bytes
                                    )
                                }
                            ),
                            in: 0.001...1
                        )
                    } header: {
                        Text("Max Cache size")
                    }

                    Section {
                        Slider(value: $configuration.maxLevelOfIntegrity, in: 0.1...1)
                    } header: {
                        Text("Max Integrity")
                    }
                }
            }
            
            VStack {
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
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color(UIColor.systemBackground))
        }
    }
    
    private var currentImage: any AnimatedImage {
        let url = Bundle.main.url(forResource: selectedFormat.fileName, withExtension: selectedFormat.fileExtension)!
        let data = try! Data(contentsOf: url)
        
        switch selectedFormat {
        case .gif:
            return GifImage(name: selectedFormat.fileName, data: data)
        case .apng:
            return APNGImage(name: selectedFormat.fileName, data: data)
        case .webp:
            return WebPImage(name: selectedFormat.fileName, data: data)
        }
    }
}

extension AnimatedImageProviderConfiguration {
    public static var qualityDemo: Self {
        var configuation = Self.default
        configuation.maxMemoryUsage = .init(value: 1, unit: .megabits)
        configuation.taskPriority = .userInitiated
        return configuation
    }
}
