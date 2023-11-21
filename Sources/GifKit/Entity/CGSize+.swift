import Foundation

func min(_ x: CGSize, _ y: CGSize) -> CGSize {
    let areaX = x.width * x.height
    let areaY = y.width * y.height
    return areaX < areaY ? x : y
}
