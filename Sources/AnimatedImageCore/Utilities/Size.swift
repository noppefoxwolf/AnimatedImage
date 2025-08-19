import Foundation
import simd

/// SIMD2<Int>をラップしたサイズ構造体
public struct Size: Sendable, Hashable {
    private var vector: SIMD2<Int>
    
    public var width: Int {
        get { vector.x }
        set { vector.x = newValue }
    }
    public var height: Int {
        get { vector.y }
        set { vector.y = newValue }
    }
    
    public init(width: Int, height: Int) {
        self.vector = SIMD2(width, height)
    }
    
    public init(_ vector: SIMD2<Int>) {
        self.vector = vector
    }
    
    public static let zero = Size(width: 0, height: 0)
}

// MARK: - CGSize変換
extension Size {
    public init(_ cgSize: CGSize) {
        self.init(width: Int(cgSize.width), height: Int(cgSize.height))
    }
    
    public var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

// MARK: - 比較演算
extension Size {
    public func isLessThanOrEqualTo(_ size: Size) -> Bool {
        width <= size.width && height <= size.height
    }
    
    public var area: Int {
        width * height
    }
}

// MARK: - Core Graphics変換
extension Size {
    public func applying(_ transform: CGAffineTransform) -> Size {
        Size(cgSize.applying(transform))
    }
}

func min(_ x: Size, _ y: Size) -> Size {
    let areaX = x.width * x.height
    let areaY = y.width * y.height
    return areaX < areaY ? x : y
}
