import SwiftUI
import UIKit

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                List {
                    NavigationLink(destination: SwiftUIDemoView()) { Text("SwiftUI Demo") }
                    NavigationLink(destination: UIKitDemoView()) { Text("UIKit Demo") }
                }
            })
        }
    }
}

