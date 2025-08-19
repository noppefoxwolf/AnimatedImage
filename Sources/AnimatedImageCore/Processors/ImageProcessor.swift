import Foundation
import QuartzCore
import os

struct ImageProcessor: Sendable {
    struct FrameConfiguration: Sendable {
        let optimizedSize: Size
        let indices: [Int]
        let delayTime: Double
        let interpolationQuality: CGInterpolationQuality

        init(
            optimizedSize: Size,
            indices: [Int],
            delayTime: Double,
            interpolationQuality: CGInterpolationQuality
        ) {
            self.optimizedSize = optimizedSize
            self.indices = indices
            self.delayTime = delayTime
            self.interpolationQuality = interpolationQuality
        }
    }

    struct ProcessingResult: Sendable {
        let frameConfiguration: FrameConfiguration
        let generatedImages: [Int: CGImage]

        init(frameConfiguration: FrameConfiguration, generatedImages: [Int: CGImage]) {
            self.frameConfiguration = frameConfiguration
            self.generatedImages = generatedImages
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

        let frameInfo = optimizeFrameSelection(
            for: optimizedSize,
            imageCount: imageCount,
            image: image
        )
        
        let frameConfiguration = FrameConfiguration(
            optimizedSize: optimizedSize,
            indices: frameInfo.displayIndices,
            delayTime: frameInfo.delayTime,
            interpolationQuality: configuration.interpolationQuality
        )

        let generatedImages = await prewarmFrameImages(frameConfiguration, image: image)

        return ProcessingResult(
            frameConfiguration: frameConfiguration,
            generatedImages: generatedImages
        )
    }

    func isValidRenderSize(_ renderSize: Size) -> Bool {
        sizeOptimizer.isValidRenderSize(renderSize)
    }

    func optimizedSize(for renderSize: Size, scale: CGFloat, imageSize: Size, imageCount: Int = 1) -> Size {
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
    ) -> (displayIndices: [Int], delayTime: Double) {
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

        return (displayIndices: decimationResult.displayIndices, delayTime: decimationResult.delayTime)
    }

    func prewarmFrameImages(
        _ frameConfiguration: FrameConfiguration,
        image: any AnimatedImage
    ) async -> [Int: CGImage] {
        var generatedImages: [Int: CGImage] = [:]

        await withTaskGroup(of: (Int, CGImage?).self) { taskGroup in
            for index in Set(frameConfiguration.indices) {
                taskGroup.addTask {
                    let processedImage = await createAndCacheImage(
                        image: image,
                        size: frameConfiguration.optimizedSize,
                        index: index,
                        interpolationQuality: frameConfiguration.interpolationQuality
                    )
                    return (index, processedImage)
                }
            }

            for await (index, processedImage) in taskGroup {
                if let processedImage {
                    generatedImages[index] = processedImage
                }
            }
        }

        return generatedImages
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
