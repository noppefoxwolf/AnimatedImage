import Foundation
import QuartzCore
import os

struct ImageProcessor: Sendable {
    struct ProcessingResult: Sendable {
        let indices: [Int]
        let delayTime: Double

        init(indices: [Int], delayTime: Double) {
            self.indices = indices
            self.delayTime = delayTime
        }
    }

    private let configuration: AnimatedImageProviderConfiguration
    private let cache: Cache<Int, CGImage>
    private let sizeOptimizer: SizeOptimizer

    init(configuration: AnimatedImageProviderConfiguration, cache: Cache<Int, CGImage>) {
        self.configuration = configuration
        self.cache = cache
        self.sizeOptimizer = SizeOptimizer()
    }

    func processAnimatedImage(
        renderSize: Size,
        scale: CGFloat,
        image: any AnimatedImage
    ) async -> ProcessingResult? {
        let imageCount = autoreleasepool { image.imageCount }
        guard imageCount > 1 else { return nil }
        guard !Task.isCancelled else { return nil }

        guard let firstImage = image.image(at: 0) else { return nil }
        let optimizedSize = optimizedSize(
            for: renderSize,
            scale: scale,
            imageSize: Size(width: firstImage.width, height: firstImage.height),
            imageCount: imageCount
        )
        guard isValidRenderSize(optimizedSize) else { return nil }
        guard !Task.isCancelled else { return nil }

        let result = optimizeFrameSelection(
            for: optimizedSize,
            imageCount: imageCount,
            image: image
        )

        await prewarmFrameImages(
            indices: result.indices,
            optimizedSize: optimizedSize,
            interpolationQuality: configuration.interpolationQuality,
            image: image
        )
        
        return result
    }

    func isValidRenderSize(_ renderSize: Size) -> Bool {
        sizeOptimizer.isValidRenderSize(renderSize)
    }

    func optimizedSize(for renderSize: Size, scale: CGFloat, imageSize: Size, imageCount: Int = 1)
        -> Size
    {
        sizeOptimizer.optimizedSize(
            for: renderSize,
            maxSize: configuration.maxSize,
            scale: scale,
            imageSize: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: configuration.maxMemoryUsage.converted(to: .bytes).value
        )
    }

    func integrityLevel(for imageSize: Size, imageCount: Int) -> Double {
        sizeOptimizer.integrityLevel(
            for: imageSize,
            imageCount: imageCount,
            maxMemoryUsage: configuration.maxMemoryUsage.converted(to: .bytes).value,
            maxLevelOfIntegrity: configuration.maxLevelOfIntegrity
        )
    }

    func optimizeFrameSelection(
        for imageSize: Size,
        imageCount: Int,
        image: any AnimatedImage
    ) -> ProcessingResult {
        let levelOfIntegrity = integrityLevel(for: imageSize, imageCount: imageCount)

        let delayTimes = (0..<imageCount)
            .map { index in
                autoreleasepool { image.delayTime(at: index) }
            }

        let decimator = FrameDecimator()
        let decimationResult = decimator.optimizeFrameSelection(
            delays: delayTimes,
            levelOfIntegrity: levelOfIntegrity
        )
        
        return ProcessingResult(
            indices: decimationResult.displayIndices, delayTime: decimationResult.delayTime
        )
    }

    func prewarmFrameImages(
        indices: [Int],
        optimizedSize: Size,
        interpolationQuality: CGInterpolationQuality,
        image: any AnimatedImage
    ) async {
        await withTaskGroup { taskGroup in
            for index in Set(indices) {
                taskGroup.addTask {
                    let processedImage = await createAndCacheImage(
                        image: image,
                        size: optimizedSize,
                        index: index,
                        interpolationQuality: interpolationQuality
                    )
                    return (index, processedImage)
                }
            }

            await taskGroup.waitForAll()
        }
    }

    func createAndCacheImage(
        image: any AnimatedImage,
        size: Size,
        index: Int,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let cgImage = autoreleasepool { image.image(at: index) }

        guard !Task.isCancelled else { return nil }
        guard let cgImage = cgImage else { return nil }

        let processor = CGImageProcessor()
        let decodedImage = await processor.decoded(
            image: cgImage,
            for: size,
            interpolationQuality: interpolationQuality
        )

        guard !Task.isCancelled else { return nil }
        if let decodedImage {
            cache.insert(decodedImage, forKey: index)
        }
        return decodedImage
    }
}
