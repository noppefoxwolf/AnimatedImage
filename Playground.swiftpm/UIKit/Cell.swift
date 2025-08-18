import UIKit
import AnimatedImage

final class Cell: UITableViewCell {

    let animatedImageView = AnimatedImageView(frame: .null)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        animatedImageView.contentMode = .scaleAspectFit
        animatedImageView.translatesAutoresizingMaskIntoConstraints = false
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
