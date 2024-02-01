//  Copyright (c) 2015-present Snowplow Analytics Ltd. All rights reserved.
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

import UIKit
import WebKit
import SnowplowTracker

class WebViewController: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet weak var urlField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Snowplow.subscribeToWebViewEvents(with: webView.configuration)
    }
    
    @IBAction func navigatePressed(_ sender: Any) {
        if let urlText = urlField.text, let url = URL(string: urlText) {
            webView.load(URLRequest(url: url))
        }
    }

}
