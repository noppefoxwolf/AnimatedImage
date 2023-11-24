import SwiftUI
import AnimatedImage
import AnimatedImageSwiftUI

struct QualityDemoView: View {
    @State
    var configuration: AnimatedImageViewConfiguration = .qualityDemo
    
    @State
    var width: Double = 100
    
    var body: some View {
        VStack {
            Spacer()
            
            let url = Bundle.main.url(forResource: "elephant", withExtension: "png")!
            let data = try! Data(contentsOf: url)
            let image = APNGImage(data: data)
            AnimatedImagePlayer(image: image)
                .environment(\.animatedImageViewConfiguration, configuration)
                .frame(width: width, height: width)
                .background(Color.gray)
            
            HStack {
                Text("Render Width")
                Slider(value: $width, in: 1...100)
            }
            
            HStack {
                Text("Max Width")
                Slider(value: $configuration.maxSize.width, in: 1...32)
            }
            
            HStack {
                Text("Max Cache size")
                Slider(
                    value: Binding<Double>(get: {
                        Double(configuration.maxByteCount) / (1 * 1024 * 1024)
                    }, set: { newValue in
                        configuration.maxByteCount = Int64((1 * 1024 * 1024) * newValue)
                    }),
                    in: 0.001...1
                )
            }
            
            HStack {
                Text("Max Integrity")
                Slider(value: $configuration.maxLevelOfIntegrity, in: 0.1...1)
            }
        }.padding()
    }
}

extension AnimatedImageViewConfiguration {
    public static var qualityDemo: AnimatedImageViewConfiguration {
        var configuation = AnimatedImageViewConfiguration.default
        configuation.maxByteCount = 1 * 1024 * 1024
        configuation.taskPriority = .userInitiated
        return configuation
    }
}
