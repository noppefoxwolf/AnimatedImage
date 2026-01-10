import SwiftUI
import UIKit

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            NavigationView(content: {
                List {
                    Section {
                        NavigationLink {
                            SwiftUIDemoView()
                        } label: {
                            Text("SwiftUI Demo")
                        }

                        NavigationLink {
                            UIKitDemoView()
                        } label: {
                            Text("UIKit Demo")
                        }
                    }
                    Section {
                        NavigationLink {
                            FormatDemoView()
                        } label: {
                            Text("Format Demo")
                        }
                        NavigationLink {
                            PreDecodeDemoView()
                        } label: {
                            Text("Pre-decode Demo")
                        }
                        NavigationLink {
                            QualityDemoView()
                        } label: {
                            Text("Adjust quality Demo")
                        }
                        NavigationLink {
                            SynchronizeDemoView()
                        } label: {
                            Text("Synchronize Demo")
                        }
                    }
                }
            })
        }
    }
}
