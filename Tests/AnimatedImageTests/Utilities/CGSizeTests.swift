@testable import AnimatedImage
import Testing
import Foundation

@Suite
struct CGSizeTests {
    @Test
    func isLessThanEqual() async throws {
        let size = CGSize(width: 100, height: 100)
        let otherSize1 = CGSize(width: 100, height: 100)
        #expect(size.isLessThanOrEqualTo(otherSize1) == true)
        let otherSize2 = CGSize(width: 10, height: 10)
        #expect(size.isLessThanOrEqualTo(otherSize2) == false)
        let otherSize3 = CGSize(width: 200, height: 200)
        #expect(size.isLessThanOrEqualTo(otherSize3) == true)
    }
}
