import AnimatedImage
import UIKit

class CollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        setupLayout()
    }

    private func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        collectionView.collectionViewLayout = layout
    }

    let items: [AnimatedImageResourceItem] = {
        let dataSource = (0..<50)
            .reduce(
                into: [],
                { result, _ in
                    result += AnimatedImageResource.examples
                }
            )
        return dataSource.map(AnimatedImageResourceItem.init(rawValue:))
    }()

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            as! CollectionViewCell
        let item = items[indexPath.item]

        switch item.rawValue {
        case .apng(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "png")!
            let data = try! Data(contentsOf: url)
            let image = APNGImage(name: name, data: data)
            cell.animatedImageView.image = image
        case .gif(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            let image = GifImage(name: name, data: data)
            cell.animatedImageView.image = image
        case .webp(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "webp")!
            let data = try! Data(contentsOf: url)
            let image = WebPImage(name: name, data: data)
            cell.animatedImageView.image = image
        }

        return cell
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? CollectionViewCell)?.animatedImageView.startAnimating()
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        (cell as? CollectionViewCell)?.animatedImageView.stopAnimating()
    }
}
