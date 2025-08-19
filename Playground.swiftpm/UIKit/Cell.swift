import AnimatedImage
import UIKit

final class CollectionViewCell: UICollectionViewCell {

    let animatedImageView = AnimatedImageView(frame: .null)

    override init(frame: CGRect) {
        super.init(frame: frame)
        animatedImageView.configuration = .performance
        animatedImageView.contentMode = .scaleAspectFit
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
        animatedImageView.backgroundColor = .systemGray4
        contentView.addSubview(animatedImageView)
        NSLayoutConstraint.activate([
            animatedImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: animatedImageView.bottomAnchor
            ),
            animatedImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: animatedImageView.trailingAnchor
            ),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
