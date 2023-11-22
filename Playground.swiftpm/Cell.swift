import UIKit
import GifKit

final class Cell: UITableViewCell {

    let sequencialImageView = SequencialImageView(frame: .null)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sequencialImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sequencialImageView)
        NSLayoutConstraint.activate([
            sequencialImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),
            contentView.bottomAnchor.constraint(
                equalTo: sequencialImageView.bottomAnchor
            ),
            sequencialImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),
            contentView.trailingAnchor.constraint(
                equalTo: sequencialImageView.trailingAnchor
            ),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
