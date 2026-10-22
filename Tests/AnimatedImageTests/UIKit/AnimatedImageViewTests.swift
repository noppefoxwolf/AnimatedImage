#if canImport(UIKit)
import AnimatedImageCore
import Testing
import UIKit

@testable import _UIKit_AnimatedImage

@MainActor
struct AnimatedImageViewTests {
    @Test("Repeated layout and image assignments reuse the pending and completed request")
    func duplicateRequests() async throws {
        let image = makeImage()
        let view = AnimatedImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.image = image
        let task = try #require(view.decodeTask)

        view.image = image
        view.layoutSubviews()
        #expect(view.decodeTask == task)

        await task.value
        view.layoutSubviews()
        #expect(view.decodeTask == task)
        view.updateContents(for: 0)
        #expect(view.contents != nil)
        view.image = nil
    }

    @Test("Changing size or scale creates a new request", arguments: [true, false])
    func changedLayout(changesSize: Bool) async throws {
        let image = makeImage()
        let loader = AnimatedImageLoader()
        let view = AnimatedImageView(frame: .zero)
        view.decode(loader, decodeImage: image, layout: (CGSize(width: 20, height: 20), 1))
        let firstTask = try #require(view.decodeTask)
        await firstTask.value

        let size = CGSize(width: changesSize ? 30 : 20, height: 20)
        view.decode(loader, decodeImage: image, layout: (size, changesSize ? 1 : 2))
        let nextTask = try #require(view.decodeTask)
        #expect(nextTask != firstTask)
        await nextTask.value
    }

    @Test("Replacing an image cancels its waiter and clearing prevents stale display")
    func replacedImage() async throws {
        let view = AnimatedImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        view.image = makeImage()
        let firstTask = try #require(view.decodeTask)
        view.image = makeImage()
        let nextTask = try #require(view.decodeTask)
        #expect(nextTask != firstTask)
        #expect(firstTask.isCancelled)

        view.image = nil
        #expect(nextTask.isCancelled)
        await firstTask.value
        await nextTask.value
        view.updateContents(for: 0)
        #expect(view.contents == nil)
        #expect(view.decodeTask == nil)
    }

    @Test("A zero-size layout does not prevent a later valid request")
    func initiallyEmptyLayout() async throws {
        let view = AnimatedImageView(frame: .zero)
        view.image = makeImage()
        #expect(view.decodeTask == nil)
        view.frame.size = CGSize(width: 20, height: 20)
        view.layoutSubviews()
        let task = try #require(view.decodeTask)
        await task.value
        view.updateContents(for: 0)
        #expect(view.contents != nil)
        view.image = nil
    }

    private func makeImage() -> AnimatedImage {
        AnimatedImage(imageSource: TestImageSource(), withConfiguration: .default)
    }
}

private struct TestImageSource: AnimatedImageSource {
    let name = UUID().uuidString

    var imageCount: Int { get async { 1 } }

    func size(at index: Int) async -> Size? {
        Size(width: 20, height: 20)
    }

    func delayTime(at index: Int) async -> Double { 0.1 }

    func image(at index: Int) async -> CGImage? {
        CGContext(
            data: nil, width: 20, height: 20,
            bitsPerComponent: 8, bytesPerRow: 80,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )?.makeImage()
    }
}
#endif
