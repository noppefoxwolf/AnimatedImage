import Foundation
import QuartzCore
import os

/// アニメーション画像の処理パイプライン
public struct ImageProcessor: Sendable {

    /// フレーム設定情報
    public struct FrameConfiguration: Sendable {
        public let optimizedSize: CGSize
        public let indices: [Int]
        public let delayTime: Double
        public let scale: CGFloat
        public let interpolationQuality: CGInterpolationQuality

        public init(
            optimizedSize: CGSize,
            indices: [Int],
            delayTime: Double,
            scale: CGFloat,
            interpolationQuality: CGInterpolationQuality
        ) {
            self.optimizedSize = optimizedSize
            self.indices = indices
            self.delayTime = delayTime
            self.scale = scale
            self.interpolationQuality = interpolationQuality
        }
    }

    /// 処理結果
    public struct ProcessingResult: Sendable {
        public let frameConfiguration: FrameConfiguration
        public let generatedImages: [Int: CGImage]

        public init(frameConfiguration: FrameConfiguration, generatedImages: [Int: CGImage]) {
            self.frameConfiguration = frameConfiguration
            self.generatedImages = generatedImages
        }
    }

    private let configuration: AnimatedImageProviderConfiguration

    public init(configuration: AnimatedImageProviderConfiguration) {
        self.configuration = configuration
    }

    /// アニメーション画像を処理する
    public func processAnimatedImage(
        renderSize: CGSize,
        scale: CGFloat,
        image: any AnimatedImage
    ) async -> ProcessingResult? {
        guard isValidRenderSize(renderSize) else { return nil }
        guard !Task.isCancelled else { return nil }

        let imageCount = autoreleasepool { image.imageCount }
        guard !Task.isCancelled else { return nil }

        let optimizedSize = calculateOptimizedSize(renderSize: renderSize)
        let frameConfiguration = calculateFrameConfiguration(
            imageSize: optimizedSize,
            imageCount: imageCount,
            scale: scale,
            image: image
        )

        let generatedImages = await generateFrameImages(frameConfiguration, image: image)

        return ProcessingResult(
            frameConfiguration: frameConfiguration,
            generatedImages: generatedImages
        )
    }

    /// レンダリングサイズの検証
    public func isValidRenderSize(_ renderSize: CGSize) -> Bool {
        !CGRect(origin: .zero, size: renderSize).isEmpty
    }

    /// 最適化されたサイズを計算
    public func calculateOptimizedSize(renderSize: CGSize) -> CGSize {
        min(configuration.maxSize, renderSize)
    }

    /// フレーム設定を計算
    public func calculateFrameConfiguration(
        imageSize: CGSize,
        imageCount: Int,
        scale: CGFloat,
        image: any AnimatedImage
    ) -> FrameConfiguration {
        let imageByteCount = Int(imageSize.width) * Int(imageSize.height) * 4
        let memoryPressure =
            Double(imageByteCount * imageCount)
            / configuration.maxMemoryUsage.converted(to: .bytes).value
        let levelOfIntegrity = min(1.0 / memoryPressure, configuration.maxLevelOfIntegrity)

        let delayTimes = (0..<imageCount)
            .map { index in
                autoreleasepool { image.delayTime(at: index) }
            }

        let decimator = FrameDecimator()
        let decimationResult = decimator.optimizeFrameSelection(
            delays: delayTimes,
            levelOfIntegrity: levelOfIntegrity
        )

        return FrameConfiguration(
            optimizedSize: imageSize,
            indices: decimationResult.displayIndices,
            delayTime: decimationResult.delayTime,
            scale: scale,
            interpolationQuality: configuration.interpolationQuality
        )
    }

    /// フレーム画像を生成
    public func generateFrameImages(
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
                        scale: frameConfiguration.scale,
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

    /// 個別画像を作成
    public func createAndCacheImage(
        image: any AnimatedImage,
        size: CGSize,
        index: Int,
        scale: CGFloat,
        interpolationQuality: CGInterpolationQuality
    ) async -> CGImage? {
        let cgImage = autoreleasepool { image.image(at: index) }

        guard !Task.isCancelled else { return nil }
        guard let cgImage = cgImage else { return nil }
        
        let processor = CGImageProcessor()
        let decodedImage = await processor.decoded(
            image: cgImage,
            for: size,
            scale: scale,
            interpolationQuality: interpolationQuality
        )

        guard !Task.isCancelled else { return nil }
        return decodedImage
    }
}
