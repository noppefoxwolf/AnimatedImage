public import SwiftUI

public extension EnvironmentValues {
    @Entry
    var adjustAnimatedImageForSize: Bool = true
}

public extension View {
    func adjustAnimatedImageForSize(_ enabled: Bool) -> some View {
        environment(\.adjustAnimatedImageForSize, enabled)
    }
}
