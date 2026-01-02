import Foundation
import QuartzCore
import os

struct ImageProcessor: Sendable {
    nonisolated struct ProcessingResult: Sendable {
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

    @concurrent
    func processAnimatedImage(
        renderSize: Size,
        scale: CGFloat,
        image: any AnimatedImage
    ) async -> ProcessingResult? {
        let imageCount = await image.imageCount
        guard imageCount > 0 else { return nil }
        guard !Task.isCancelled else { return nil }

        guard let firstImage = await image.image(at: 0) else { return nil }
        let optimizedSize = await optimizedSize(
            for: renderSize,
            scale: scale,
            imageSize: Size(width: firstImage.width, height: firstImage.height),
            imageCount: imageCount
        )
        guard await isValidRenderSize(optimizedSize) else { return nil }
        guard !Task.isCancelled else { return nil }

        let result = await optimizeFrameSelection(
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
        image: any AnimatedImage
    ) async -> ProcessingResult {
        let levelOfIntegrity = await integrityLevel(for: imageSize, imageCount: imageCount)
        
        let delayTimes: [Double] = await withTaskGroup(of: (Int, Double).self, returning: [Double].self) { group in
            for index in 0..<imageCount {
                group.addTask {
                    let delay: Double = await image.delayTime(at: index)
                    return (index, delay)
                }
            }

            var results = Array(repeating: 0.0, count: imageCount)
            for await (index, delay) in group {
                results[index] = delay
            }
            return results
        }

        let decimator = await FrameDecimator()
        let decimationResult = await decimator.optimizeFrameSelection(
            delays: delayTimes,
            levelOfIntegrity: levelOfIntegrity
        )

        return ProcessingResult(
            indices: decimationResult.displayIndices,
            delayTime: decimationResult.delayTime
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
        let cgImage = await image.image(at: index)

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

