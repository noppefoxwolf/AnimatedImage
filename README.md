# AnimatedImage

[![Swift Package Manager Test](https://github.com/noppefoxwolf/AnimatedImage/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/noppefoxwolf/AnimatedImage/actions/workflows/test.yml)

High-performance animated image rendering for Swift (APNG, GIF, WebP).

![](https://github.com/noppefoxwolf/AnimatedImage/blob/main/.github/Format.gif)

## Overview

`AnimatedImage` provides a memory-aware, asynchronous pipeline to render animated images on Apple platforms. The `AnimatedImage` type combines an `AnimatedImageSource` with a `Configuration`, and decoding is performed off the main thread. UIKit and SwiftUI layers are available on UIKit platforms.

## Installation

### Swift Package Manager

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/noppefoxwolf/AnimatedImage", from: "0.2.0")
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

## Usage

### UIKit

```swift
import AnimatedImage

let data: Data = ...
let image = AnimatedImage(
    imageSource: GifImageSource(data: data),
    withConfiguration: .default
)

let imageView = AnimatedImageView(frame: .zero)
imageView.contentMode = .scaleAspectFit
imageView.image = image
```

### SwiftUI (UIKit platforms)

```swift
import AnimatedImage
import SwiftUI

struct ContentView: View {
    let image: AnimatedImage = AnimatedImage(
        imageSource: GifImageSource(data: data),
        withConfiguration: .default
    )

    var body: some View {
        AnimatedImagePlayer(image: image, contentMode: .fit)
    }
}
```

### Convenience Initializers

```swift
let urlImage = try AnimatedImage(contentsOf: url, withConfiguration: .default)
let gifImage = AnimatedImage(gif: data, withConfiguration: .default)
let apngImage = AnimatedImage(apng: data, withConfiguration: .default)
let webpImage = AnimatedImage(webP: data, withConfiguration: .default)
```

### Pre-decode / Cache

`AnimatedImageView` automatically decodes when its layout changes. If you want to warm the cache manually, use `AnimatedImageLoader`:

```swift
let loader = AnimatedImageLoader.shared
let decoded = await loader.decode(
    image,
    layout: (size: CGSize(width: 200, height: 200), scale: UIScreen.main.scale)
)
```

### Configuration

`AnimatedImage.Configuration` controls the memory budget, size limits, integrity level, and interpolation quality.

```swift
var config = AnimatedImage.Configuration.default
config.maxMemoryUsage = .init(value: 4, unit: .megabytes)
config.maxSize = Size(width: 256, height: 256)
config.maxLevelOfIntegrity = 0.9
config.interpolationQuality = .high

let image = AnimatedImage(
    imageSource: GifImageSource(data: data),
    withConfiguration: config
)
```

## Custom AnimatedImageSource

Create your own animated images by conforming to `AnimatedImageSource`:

```swift
public final class ManualAnimatedImageSource: AnimatedImageSource, @unchecked Sendable {
    public let name: String
    private let images: [CGImage]
    private let delay: Double

    public init(name: String = UUID().uuidString, images: [CGImage], delay: Double = 0.1) {
        self.name = name
        self.images = images
        self.delay = delay
    }

    public var imageCount: Int {
        get async { images.count }
    }

    public func size(at index: Int) async -> Size? {
        guard images.indices.contains(index) else { return nil }
        let image = images[index]
        return Size(width: image.width, height: image.height)
    }

    public func delayTime(at index: Int) async -> Double {
        delay
    }

    public func image(at index: Int) async -> CGImage? {
        guard images.indices.contains(index) else { return nil }
        return images[index]
    }
}
```

## Features

- Asynchronous decoding with frame decimation and size optimization
- Memory-aware caching via `AnimatedImageLoader`
- APNG/GIF/WebP support through `ImageIO`
- UIKit view (`AnimatedImageView`) and SwiftUI player (`AnimatedImagePlayer`) on UIKit platforms

## Requirements

- Swift 6.2+
- iOS 16.0+
- visionOS 1.0+
- macOS 14.0+

Note: SwiftUI/UIKit rendering is available on iOS/visionOS/macCatalyst. The AppKit layer is currently a stub.

## Architecture

- **`AnimatedImage`**: Public umbrella module that re-exports platform layers and `AnimatedImageCore`
- **`AnimatedImageCore`**: Image sources, decoding, frame selection, and configuration
- **`_UIKit_AnimatedImage`**: UIKit `AnimatedImageView` and `UpdateLink` integration
- **`_SwiftUI_AnimatedImage`**: SwiftUI `AnimatedImagePlayer` (UIKit-backed)
- **`UpdateLink`**: Abstraction over `UIUpdateLink` (iOS 18+/visionOS 2+) and `CADisplayLink`
- **`_AppKit_AnimatedImage`**: Placeholder target for future AppKit support

## Apps Using AnimatedImage

<p float="left">
    <a href="https://apps.apple.com/app/id1668645019"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/dev.noppe.snowfox.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6470347919"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/lynnpd.threadpd.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6736725704"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/com.nintendo.znsa.png" height="65"></a>
    <a href="https://apps.apple.com/app/id6747976082"><img src="https://github.com/noppefoxwolf/markdown-resources/blob/main/app-icons/com.zonepane.zero.png" height="65"></a>
</p>

## Build & Test

- Build: `swift build` (use `-c release` for optimized builds)
- Test: `swift test`
  - Filter: `swift test --filter ImageProcessorTests`
- Example local demo: open `Playground.swiftpm` in Xcode and run

CI runs on macOS 26 with Xcode 26.2 (see `.github/workflows/test.yml`).

## License

AnimatedImage is available under the MIT license. See the LICENSE file for more info.
