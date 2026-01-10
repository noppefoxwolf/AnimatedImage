public import Foundation

extension AnimatedImage {
    public convenience init(
        contentsOf url: URL,
        withConfiguration configuration: AnimatedImage.Configuration
    ) throws {
        let data = try Data(contentsOf: url)
        let imageSource: any AnimatedImageSource
        switch url.pathExtension.lowercased() {
        case "png":
            imageSource = APNGImageSource(name: url.lastPathComponent, data: data)
        case "webp":
            imageSource = WebPImageSource(name: url.lastPathComponent, data: data)
        case "gif":
            imageSource = GifImageSource(name: url.lastPathComponent, data: data)
        default:
            imageSource = APNGImageSource(name: url.lastPathComponent, data: data)
        }
        self.init(
            imageSource: imageSource,
            withConfiguration: configuration
        )
    }
    
    public convenience init(
        webP data: Data,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        let imageSource = WebPImageSource(data: data)
        self.init(
            imageSource: imageSource,
            withConfiguration: configuration
        )
    }
    
    public convenience init(
        apng data: Data,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        let imageSource = APNGImageSource(data: data)
        self.init(
            imageSource: imageSource,
            withConfiguration: configuration
        )
    }
    
    public convenience init(
        gif data: Data,
        withConfiguration configuration: AnimatedImage.Configuration
    ) {
        let imageSource = GifImageSource(data: data)
        self.init(
            imageSource: imageSource,
            withConfiguration: configuration
        )
    }
}
