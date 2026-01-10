# Migration Guide: 0.1 → 0.2

This document summarizes the changes from `main` and the steps to migrate from v0.1 to v0.2.

## Breaking Changes
- `AnimatedImage` (old protocol) → `AnimatedImageSource` (new protocol)
- `APNGImage / GifImage / WebPImage` → `APNGImageSource / GifImageSource / WebPImageSource`
- `AnimatedImageProviderConfiguration` → `AnimatedImage.Configuration` (nested type)
- `AnimatedImageProvider` removed (internal pipeline moved to `AnimatedImage` + `AnimatedImageLoader`)
- `AnimatedImageView.configuration` removed (set configuration when creating `AnimatedImage`)
- `startAnimating()/stopAnimating()` removed (animation auto-managed on add/remove)
- `AnimatableCGImageView.willUpdateContents` → `updateContents`
- `AnimatedImagePlayer` now accepts `AnimatedImage` (not `any AnimatedImage`)
- SwiftUI `animatedImageProviderConfiguration` environment key removed

## Replacement Map
- `AnimatedImageProviderConfiguration` → `AnimatedImage.Configuration`
- `.environment(\.animatedImageProviderConfiguration, ...)` → remove
- `AnimatedImageView.configuration = ...` → set on `AnimatedImage` init
- `APNGImage(...)` → `APNGImageSource(...)` + `AnimatedImage(imageSource:withConfiguration:)`
- `startAnimating()/stopAnimating()` → remove
- `AnimatedImage` (old) → `AnimatedImageSource`

## UIKit Migration Example
### v0.1
```swift
let image = APNGImage(data: data)
let imageView = AnimatedImageView(frame: .zero)
imageView.image = image
imageView.startAnimating()
```

### v0.2
```swift
let imageSource = APNGImageSource(data: data)
let image = AnimatedImage(imageSource: imageSource, withConfiguration: .default)

let imageView = AnimatedImageView(frame: .zero)
imageView.image = image
// startAnimating/stopAnimating are no longer needed
```

## SwiftUI Migration Example
### v0.1
```swift
let config: AnimatedImageProviderConfiguration = .default
AnimatedImagePlayer(image: GifImage(data: data))
    .environment(\.animatedImageProviderConfiguration, config)
```

### v0.2
```swift
let image = AnimatedImage(gif: data, withConfiguration: .default)
AnimatedImagePlayer(image: image)
```

## Custom Implementation Migration
### v0.1
```swift
public final class ManualAnimatedImage: AnimatedImage, @unchecked Sendable {
    public let name: String
    public let imageCount: Int
    // implement size(at:), delayTime(at:), image(at:)
}
```

### v0.2
```swift
public final class ManualAnimatedImageSource: AnimatedImageSource, @unchecked Sendable {
    public let name: String
    public let imageCount: Int
    // implement size(at:), delayTime(at:), image(at:)
}

let source = ManualAnimatedImageSource(...)
let image = AnimatedImage(imageSource: source, withConfiguration: .default)
```

## Notes
- `AnimatedImageProviderConfiguration.taskPriority` is removed.
  Use `AnimatedImageLoader.decode(_:layout:taskPriority:)` if you need to control task priority.
- If you subclass `AnimatableCGImageView`, rename `willUpdateContents` to `updateContents`.
