# AnimatedImage

High-performance animation image library for Swift.

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Format.gif)

## Installation

### Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/noppefoxwolf/AnimatedImage", from: "0.0.14")
    ],
    targets: [
        .target(
            name: "YourTarget",
            dependencies: [
                .product(name: "AnimatedImage", package: "AnimatedImage")
            ]
        )
    ]
)
```

## How It Works

AnimatedImage uses `AnimatedImageProvider` to pre-decode and cache animation frames for optimal performance. It dynamically optimizes frame processing based on drawing size and timing to prevent excessive cache usage. The entire processing pipeline is designed to operate independently of MainActor, ensuring smooth UI performance.

## Usage

### UIKit

```swift
import AnimatedImage

let imageView = AnimatedImageView(frame: .zero)
let image = APNGImage(data: data) // or GIFImage(data: data), WebPImage(data: data)
imageView.image = image
imageView.startAnimating()
```

### SwiftUI

```swift
import AnimatedImage

struct ContentView: View {
    @State var image = GIFImage(data: data)

    var body: some View {
        AnimatedImagePlayer(image: image)
    }
}
```

## Features

### Low MainActor Usage

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Instruments.png)

All heavy processing is performed off the main thread, keeping your UI responsive.

### Multiple Format Support

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Format.gif)

Supports APNG, GIF, and WebP animated formats.

### Automatic Quality Adjustment

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/AdjustQuality.gif)

Automatically adjusts playback quality based on available resources.

### Frame Synchronization

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Synchronize.gif)

Synchronizes frame updates for smooth animation playback.

### Custom Animation Support

Create your own animated images by conforming to the `AnimatedImage` protocol:

```swift
public final class ManualAnimatedImage: AnimatedImage {
    public let name: String
    public let imageCount: Int
    private let images: [CGImage]
    
    public init(name: String = UUID().uuidString, images: [CGImage]) {
        self.name = name
        self.images = images
        self.imageCount = images.count
    }
    
    public func delayTime(at index: Int) -> Double {
        0.1
    }
    
    public func image(at index: Int) -> CGImage? {
        images[index]
    }
}
```

## Requirements

- Swift 6.1+
- iOS 16.0+
- macOS 14.0+
- visionOS 1.0+

## Architecture

The library consists of multiple internal modules unified under a single product:

- **`AnimatedImageCore`**: Core animation logic and image processing
  - Image decoders for APNG, GIF, and WebP
  - `AnimatedImageProvider` for animation caching and frame management
  - Image processing and timing calculations
- **Platform-specific modules**:
  - `_UIKit_AnimatedImage`: UIKit support with `AnimatedImageView`
  - `_AppKit_AnimatedImage`: macOS support (in development)
  - `_SwiftUI_AnimatedImage`: SwiftUI integration with `AnimatedImagePlayer`
- **`UpdateLink`**: Display link and frame timing control

## Apps Using AnimatedImage

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/dev.noppe.snowfox.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6470347919"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/lynnpd.threadpd.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6736725704"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/com.nintendo.znsa.png" height="65"></a>
</p>

## License

AnimatedImage is available under the MIT license. See the LICENSE file for more info.
