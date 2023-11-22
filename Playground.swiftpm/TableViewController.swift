import UIKit
import GifKit

class TableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }
    enum ImageResource {
        case apng(String)
        case gif(String)
        case webp(String)
    }
    
    // https://emoji.gg/pack/6241-blobs#
    var resources: [ImageResource] = [
        .apng("elephant"),
        .webp("animated-webp-supported"),
        .gif("1342-splash"),
        .gif("1904-blob-dancing"),
        .gif("2671-blobsupersaiyan"),
        .gif("2697-cookieblob"),
        .gif("4817-blobbottleflip"),
        .gif("5883-blob"),
        .gif("5907-dracthyrdance"),
        .gif("6292-blob-cat-whacky-fast"),
        .gif("7164-blobtrash"),
        .gif("7514-bouncingrainbowblob"),
        .gif("7766-blobpokemon"),
        .gif("7896-blob-jam"),
        .gif("7953-blobknight"),
        .gif("8551-blob-swallow"),
        .gif("8843-blobdrum"),
        .gif("8899-blob-cat-pop"),
        .gif("8967-blob-cat-dance"),
        .gif("8996-blob"),
        .gif("9507-blobsnow"),
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "Cell",
            for: indexPath
        ) as! Cell
        let resource = resources[indexPath.row]
        switch resource {
        case .apng(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "png")!
            let data = try! Data(contentsOf: url)
            let image = APNGImage(name: name, data: data)
            cell.sequencialImageView.image = image
        case .gif(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "gif")!
            let data = try! Data(contentsOf: url)
            let image = GifImage(name: name, data: data)
            cell.sequencialImageView.image = image
        case .webp(let name):
            let url = Bundle.main.url(forResource: name, withExtension: "webp")!
            let data = try! Data(contentsOf: url)
            let image = WebPImage(name: name, data: data)
            cell.sequencialImageView.image = image
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.sequencialImageView.startAnimating()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.sequencialImageView.stopAnimating()
    }
}

