# AnimatedImage

High-performance animation image library.

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Format.gif)

# Install

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/noppefoxwolf/AnimatedImage", from: "0.0.x")
    ],
)
```

# How It Works

AnimatedImage pre-decodes and caches all animation frames.
Optimize the number of drawing frames from the drawing size and drawing timestamp to prevent the cache size from becoming too large.
It is designed so that all processing does not depend on the MainActor.

# Usage

## UIKit

```swift
let imageView = AnimatedImage(frame: .null)
let image = APNGImage(data: data)
imageView.image = image
imageView.startAnimating()
```

## SwiftUI

```swift
@State var image = GIFImage(data: data)

var body: some View {
    AnimatedImagePlayer(image: image)
}
```

# Features

## Low access main actor

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Instruments.png)

## Support playback APNG, GIF, WebP

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Format.gif)

## Automatically adjust playback quality

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/AdjustQuality.gif)

## Synchronize frame update 

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Synchronize.gif)

## Customizable playback format

```swift
public final class ManualAnimatedImage: AnimatedImage {
    public let name: String
    let images: [CGImage]
    
    public init(name: String = UUID().uuidString, images: [CGImage]) {
        self.name = name
        self.images = images
    }
    
    public nonisolated func makeImageCount() -> Int {
        images.count
    }
    
    public nonisolated func makeDelayTime(at index: Int) -> Double {
        0.1
    }
    
    public nonisolated func makeImage(at index: Int) -> CGImage? {
        images[index]
    }
}
```

# Required

- Swift 6.0
- iOS 16

## Apps Using

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/dev.noppe.snowfox.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6470347919"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/lynnpd.threadpd.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6736725704"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/com.nintendo.znsa.png" height="65"></a>
</p>

# License

AnimatedImage is available under the MIT license. See the LICENSE file for more info.
