import UIKit
import GifKit

class TableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }
    
    // https://emoji.gg/pack/6241-blobs#
    var resources: [String] = [
        "1342-splash",
        "1904-blob-dancing",
        "2671-blobsupersaiyan",
        "2697-cookieblob",
        "4817-blobbottleflip",
        "5883-blob",
        "5907-dracthyrdance",
        "6292-blob-cat-whacky-fast",
        "7164-blobtrash",
        "7514-bouncingrainbowblob",
        "7766-blobpokemon",
        "7896-blob-jam",
        "7953-blobknight",
        "8551-blob-swallow",
        "8843-blobdrum",
        "8899-blob-cat-pop",
        "8967-blob-cat-dance",
        "8996-blob",
        "9507-blobsnow",
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
        let url = Bundle.main.url(forResource: resource, withExtension: "gif")!
        let data = try! Data(contentsOf: url)
        let image = GifImage(data: data)
        cell.gifImageView.image = image
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.gifImageView.startAnimating()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.gifImageView.stopAnimating()
    }
}

