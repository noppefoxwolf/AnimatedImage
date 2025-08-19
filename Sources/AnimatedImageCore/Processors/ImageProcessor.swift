import Foundation
import QuartzCore
import os

/// アニメーション画像の処理パイプライン
public struct ImageProcessor: Sendable {

    /// フレーム設定情報
    public struct FrameConfiguration: Sendable {
        public let optimizedSize: Size
        public let indices: [Int]
        public let delayTime: Double
        public let scale: CGFloat
        public let interpolationQuality: CGInterpolationQuality

        public init(
            optimizedSize: Size,
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
        renderSize: Size,
        scale: CGFloat,
        image: any AnimatedImage
    ) async -> ProcessingResult? {
        guard isValidRenderSize(renderSize) else { return nil }
        guard !Task.isCancelled else { return nil }

        let imageCount = autoreleasepool { image.imageCount }
        guard !Task.isCancelled else { return nil }

        let optimizedSize = optimizedSize(for: renderSize)
        let frameConfiguration = frameConfiguration(
            for: optimizedSize,
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
    public func isValidRenderSize(_ renderSize: Size) -> Bool {
        !renderSize.isEmpty
    }

    /// 最適化されたサイズを計算
    public func optimizedSize(for renderSize: Size) -> Size {
        min(configuration.maxSize, renderSize)
    }

    /// 品質レベルを計算
    /// 
    /// メモリ使用量に基づいて品質レベルを決定します：
    /// - メモリ圧迫度が低い（設定値の半分以下）→ 上限値で制限
    /// - メモリ圧迫度が1.0（設定値と同じ）→ 1.0（全フレーム表示）
    /// - メモリ圧迫度が2.0（設定値の2倍）→ 0.5（半分のフレームを間引き）
    /// 
    /// - Parameters:
    ///   - imageSize: 画像サイズ
    ///   - imageCount: フレーム数
    /// - Returns: 品質レベル（0.0〜1.0）
    public func integrityLevel(for imageSize: Size, imageCount: Int) -> Double {
        let imageByteCount = imageSize.width * imageSize.height * 4
        let maxMemoryUsage = configuration.maxMemoryUsage.converted(to: .bytes).value
        let memoryPressure = Double(imageByteCount * imageCount) / maxMemoryUsage
        return min(1.0 / memoryPressure, configuration.maxLevelOfIntegrity)
    }

    /// フレーム設定を計算
    public func frameConfiguration(
        for imageSize: Size,
        imageCount: Int,
        scale: CGFloat,
        image: any AnimatedImage
    ) -> FrameConfiguration {
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
        size: Size,
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
