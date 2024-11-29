//
//  Created by Daniel on 12/13/20.
//

import UIKit

class RedditHandler: NewsTableHandler {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RedditCell.identifier) as! RedditCell

        let article = articles[indexPath.row]
        cell.load(article: article, downloader: ImageDownloader.shared)
        cell.loadLogo(urlString: article.urlToSourceLogo,
                      size: RedditCell.logoSize,
                      downloader: ImageDownloader.shared)

        return cell
    }

}

