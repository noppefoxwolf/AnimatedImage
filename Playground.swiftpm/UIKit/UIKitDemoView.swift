import SwiftUI

struct UIKitDemoView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        TableViewController(style: .plain)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
