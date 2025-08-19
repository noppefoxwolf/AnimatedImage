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
        public let interpolationQuality: CGInterpolationQuality

        public init(
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

        let frameConfiguration = frameConfiguration(
            for: optimizedSize,
            imageCount: imageCount,
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
    /// アスペクト比、メモリ制約、スケールを考慮した包括的なサイズ最適化
    public func optimizedSize(for renderSize: Size, scale: CGFloat, imageSize: Size, imageCount: Int = 1) -> Size {
        // 設定された最大サイズとレンダリングサイズの制約を適用
        let maxSize = min(configuration.maxSize, renderSize)
        
        // 元画像サイズを超えないよう制約
        let constrainedSize = Size(
            width: min(maxSize.width, imageSize.width),
            height: min(maxSize.height, imageSize.height)
        )
        
        // アスペクト比を維持した最適サイズを計算
        let aspectOptimizedSize = aspectFitSize(of: imageSize, in: constrainedSize)
        
        // スケールを適用
        let scaledSize = aspectOptimizedSize.applying(
            CGAffineTransform(scaleX: scale, y: scale)
        )
        
        // メモリ制約を考慮したサイズ調整
        let memoryAdjustedSize = adjustSizeForMemoryConstraints(scaledSize, imageCount: imageCount)
        
        return memoryAdjustedSize
    }
    
    /// アスペクト比を維持したサイズ計算
    private func aspectFitSize(of currentSize: Size, in maxSize: Size) -> Size {
        let aspectWidth = CGFloat(maxSize.width) / CGFloat(currentSize.width)
        let aspectHeight = CGFloat(maxSize.height) / CGFloat(currentSize.height)
        let scalingFactor = min(aspectWidth, aspectHeight)
        let transform = CGAffineTransform(scaleX: scalingFactor, y: scalingFactor)
        return currentSize.applying(transform)
    }
    
    /// メモリ制約を考慮したサイズ調整
    /// メモリ使用量が制限を超える場合、サイズを縮小して調整します
    private func adjustSizeForMemoryConstraints(
        _ size: Size, 
        imageCount: Int, 
        targetMemoryRatio: Double = 0.8
    ) -> Size {
        let imageByteCount = size.width * size.height * 4
        let totalMemoryUsage = Double(imageByteCount * imageCount)
        let maxMemoryUsage = configuration.maxMemoryUsage.converted(to: .bytes).value
        let targetMemoryUsage = maxMemoryUsage * targetMemoryRatio
        
        if totalMemoryUsage <= targetMemoryUsage {
            return size
        }
        
        // メモリ制限を超える場合、サイズを縮小
        let reductionFactor = sqrt(targetMemoryUsage / totalMemoryUsage)
        let transform = CGAffineTransform(scaleX: reductionFactor, y: reductionFactor)
        return size.applying(transform)
    }

    /// 品質レベルを計算
    /// 
    /// メモリ使用量に基づいて品質レベルを決定します：
    /// - メモリ圧迫度が低い（設定値の半分以下）→ 上限値で制限
    /// - メモリ圧迫度が1.0（設定値と同じ）→ 1.0（全フレーム表示）
    /// - メモリ圧迫度が2.0（設定値の2倍）→ 0.5（半分のフレームを間引き）
    /// 
    /// - Parameters:
    ///   - imageSize: 画像サイズ（optimizedSizeで既に調整済み）
    ///   - imageCount: フレーム数
    ///   - scale: 画像スケール（既に適用済み）
    /// - Returns: 品質レベル（0.0〜1.0）
    public func integrityLevel(for imageSize: Size, imageCount: Int, scale: CGFloat = 1.0) -> Double {
        // optimizedSizeで既にスケールが適用済みのため、再度適用しない
        let imageByteCount = imageSize.width * imageSize.height * 4
        let maxMemoryUsage = configuration.maxMemoryUsage.converted(to: .bytes).value
        let memoryPressure = Double(imageByteCount * imageCount) / maxMemoryUsage
        return min(1.0 / memoryPressure, configuration.maxLevelOfIntegrity)
    }

    /// フレーム設定を計算
    public func frameConfiguration(
        for imageSize: Size,
        imageCount: Int,
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
        return decodedImage
    }
}
