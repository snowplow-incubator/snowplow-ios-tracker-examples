//  Copyright (c) 2015-2023 Snowplow Analytics Ltd. All rights reserved.
//
//  This program is licensed to you under the Apache License Version 2.0,
//  and you may not use this file except in compliance with the Apache License
//  Version 2.0. You may obtain a copy of the Apache License Version 2.0 at
//  http://www.apache.org/licenses/LICENSE-2.0.
//
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the Apache License Version 2.0 is distributed on
//  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the Apache License Version 2.0 for the specific
//  language governing permissions and limitations there under.
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd

import UIKit
import SnowplowTracker

class ScrollViewController: UIViewController, UIScrollViewDelegate, PageObserver {

    @IBOutlet weak var scrollView: UIScrollView!
    @objc dynamic var snowplowId: String! = "metrics view"
    weak var tracker : TrackerController?

    var parentPageViewController: PageViewController!
    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
        tracker = parentRef.tracker
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            stoppedScrolling()
        }
    }
    
    private func stoppedScrolling() {
        _ = Snowplow.defaultTracker()?.track(ScrollChanged(
            yOffset: Int(scrollView.contentOffset.y),
            viewHeight: Int(scrollView.frame.height),
            contentHeight: Int(scrollView.contentSize.height)
        ))
    }
    
}
