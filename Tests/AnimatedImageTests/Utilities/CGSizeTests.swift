import Foundation
import Testing

@testable import AnimatedImageCore

@Suite
struct SizeTests {
    @Test
    func isLessThanEqual() async throws {
        let size = Size(width: 100, height: 100)
        let otherSize1 = Size(width: 100, height: 100)
        #expect(size.isLessThanOrEqualTo(otherSize1) == true)
        let otherSize2 = Size(width: 10, height: 10)
        #expect(size.isLessThanOrEqualTo(otherSize2) == false)
        let otherSize3 = Size(width: 200, height: 200)
        #expect(size.isLessThanOrEqualTo(otherSize3) == true)
    }
}
