//
//  Created by Daniel on 12/12/20.
//

import UIKit

class WSJHandler: NewsTableHandler {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WSJCell.identifier) as! WSJCell

        let article = articles[indexPath.row]
        cell.load(article: article, downloader: ImageDownloader.shared)

        return cell
    }

}
