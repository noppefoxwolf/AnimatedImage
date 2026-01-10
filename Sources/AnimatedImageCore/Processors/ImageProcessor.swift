import Foundation
import QuartzCore
import os

struct ImageProcessor: Sendable {
    struct ProcessingResult {
        let size: Size
        let indices: [Int]
        let delayTime: Double
        let images: [Int: CGImage]
    }

    private let configuration: AnimatedImage.Configuration
    private let sizeOptimizer: SizeOptimizer

    init(configuration: AnimatedImage.Configuration) {
        self.configuration = configuration
        self.sizeOptimizer = SizeOptimizer()
    }

    @concurrent
    func processAnimatedImage(
        renderSize: Size,
        scale: CGFloat,
        imageSource: any AnimatedImageSource
    ) async -> ProcessingResult? {
        let imageCount = await imageSource.imageCount
        guard imageCount > 0 else { return nil }
        guard !Task.isCancelled else { return nil }

        guard let firstImageSize = await imageSource.size(at: 0) else { return nil }
        let optimizedSize = await optimizedSize(
            for: renderSize,
            scale: scale,
            imageSize: firstImageSize,
            imageCount: imageCount
        )
        guard await isValidRenderSize(optimizedSize) else { return nil }
        guard !Task.isCancelled else { return nil }

        let frameState = await optimizeFrameSelection(
            for: optimizedSize,
            imageCount: imageCount,
            imageSource: imageSource
        )

        let images = await prewarmFrameImages(
            indices: frameState.displayIndices,
            optimizedSize: optimizedSize,
            interpolationQuality: configuration.interpolationQuality,
            imageSource: imageSource
        )

        return ProcessingResult(
            size: optimizedSize,
            indices: frameState.displayIndices,
            delayTime: frameState.delayTime,
            images: images
        )
    }

    @concurrent
    func isValidRenderSize(_ renderSize: Size) async -> Bool {
        await sizeOptimizer.isValidRenderSize(renderSize)
    }

    @concurrent
    func optimizedSize(
        for renderSize: Size,
        scale: CGFloat,
        imageSize: Size,
        imageCount: Int = 1
    ) async -> Size {
        await sizeOptimizer.optimizedSize(
            for: renderSize,
            maxSize: configuration.maxSize,
            scale: scale,
            imageSize: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: configuration.maxMemoryUsage.converted(to: .bytes).value
        )
    }

    @concurrent
    func integrityLevel(for imageSize: Size, imageCount: Int) async -> Double {
        await sizeOptimizer.integrityLevel(
            for: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: configuration.maxMemoryUsage.converted(to: .bytes).value,
            maxLevelOfIntegrity: configuration.maxLevelOfIntegrity
        )
    }

    @concurrent
    func optimizeFrameSelection(
        for imageSize: Size,
        imageCount: Int,
        imageSource: any AnimatedImageSource
    ) async -> FrameDecimator.Result {
        let levelOfIntegrity = await integrityLevel(for: imageSize, imageCount: imageCount)

        let delayTimes: [Double] = await withTaskGroup(
            of: (Int, Double).self,
            returning: [Double].self
        ) { group in
            for index in 0..<imageCount {
                group.addTask {
                    let delay: Double = await imageSource.delayTime(at: index)
                    return (index, delay)
                }
            }

            var results = Array(repeating: 0.0, count: imageCount)
            for await (index, delay) in group {
                results[index] = delay
            }
            return results
        }

        let decimator = FrameDecimator()
        let decimationResult = await decimator.optimizeFrameSelection(
            delays: delayTimes,
            levelOfIntegrity: levelOfIntegrity
        )

        return decimationResult
    }

    @concurrent
    func prewarmFrameImages(
        indices: [Int],
        optimizedSize: Size,
        interpolationQuality: CGInterpolationQuality,
        imageSource: any AnimatedImageSource
    ) async -> [Int: CGImage] {
        await withTaskGroup(
            of: (Int, CGImage?).self,
            returning: [Int: CGImage].self
        ) { taskGroup in
            for index in Set(indices) {
                taskGroup.addTask {
                    let processedImage = await createImage(
                        imageSource: imageSource,
                        size: optimizedSize,
                        index: index,
                        interpolationQuality: interpolationQuality
                    )
                    return (index, processedImage)
                }
            }

            var images: [Int: CGImage] = [:]
            for await (index, image) in taskGroup {
                if let image {
                    images[index] = image
                }
            }
            return images
        }
    }

    @concurrent
    func createImage(
        imageSource: any AnimatedImageSource,
        size: Size,
        index: Int,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let cgImage = await imageSource.image(at: index)

        guard !Task.isCancelled else { return nil }
        guard let cgImage = cgImage else { return nil }

        let processor = CGImageProcessor()
        let decodedImage = await processor.decoded(
            image: cgImage,
            for: size,
            interpolationQuality: interpolationQuality
        )

        guard !Task.isCancelled else { return nil }
        return decodedImage
    }
}
