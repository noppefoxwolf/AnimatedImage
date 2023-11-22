import UIKit
import AnimatedImage
import AnimatedImageSwiftUI

class TableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
    }
    
    let resources = AnimatedImageResource.examples
    
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.animatedImageView.startAnimating()
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as? Cell)?.animatedImageView.stopAnimating()
    }
}

