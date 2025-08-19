import Foundation

func min(_ x: CGSize, _ y: CGSize) -> CGSize {
    let areaX = x.width * x.height
    let areaY = y.width * y.height
    return areaX < areaY ? x : y
}

extension CGSize {
    func isLessThanOrEqualTo(_ size: CGSize) -> Bool {
        width <= size.width && height <= size.height
    }
}
