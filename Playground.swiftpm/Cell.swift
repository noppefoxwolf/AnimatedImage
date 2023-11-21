import UIKit
import GifKit

final class Cell: UITableViewCell {

    let gifImageView = GifImageView(frame: .null)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(gifImageView)
        NSLayoutConstraint.activate([
            gifImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: gifImageView.bottomAnchor
            ),
            gifImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: gifImageView.trailingAnchor
            ),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
