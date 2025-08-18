import SwiftUI
import AnimatedImage

struct QualityDemoView: View {
    @State
    var configuration: AnimatedImageViewConfiguration = .qualityDemo
    
    @State
    var width: Double = 100
    
    var body: some View {
        VStack {
            Section {
                let url = Bundle.main.url(forResource: "elephant", withExtension: "png")!
                let data = try! Data(contentsOf: url)
                let image = APNGImage(data: data)
                AnimatedImagePlayer(image: image)
                    .environment(\.animatedImageViewConfiguration, configuration)
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
                        value: Binding<Double>(get: {
                            configuration.maxMemoryUsage.converted(to: .bytes).value / (1 * 1024 * 1024)
                        }, set: { newValue in
                            configuration.maxMemoryUsage = .init(value: (1 * 1024 * 1024) * newValue, unit: .bytes)
                        }),
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
    }
}

extension AnimatedImageViewConfiguration {
    public static var qualityDemo: AnimatedImageViewConfiguration {
        var configuation = AnimatedImageViewConfiguration.default
        configuation.maxMemoryUsage = .init(value: 1, unit: .megabits)
        configuation.taskPriority = .userInitiated
        return configuation
    }
}
