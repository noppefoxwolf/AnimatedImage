import SwiftUI

struct UIKitDemoView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        CollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
