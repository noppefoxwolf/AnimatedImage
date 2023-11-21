import SwiftUI
import UIKit

@main
struct App: SwiftUI.App {
    var body: some Scene {
        WindowGroup {
            ViewController().ignoresSafeArea()
        }
    }
}

struct ViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        TableViewController(style: .plain)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
