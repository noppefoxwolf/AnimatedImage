# AnimatedImage

High-performance animation image library.

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

# Features

- [x] Support playback APNG, GIF, WebP
- [x] Automatically adjust playback quality
- [x] Synchronize frame update 
- [x] Customizable playback format

# Required

- Swift 5.9
- iOS 16+

# License

AnimatedImage is available under the MIT license. See the LICENSE file for more info.
