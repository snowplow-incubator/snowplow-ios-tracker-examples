//
//  WebViewController.swift
//  SnowplowSwiftSPMDemo
//
//  Created by Matus Tomlein on 07/07/2022.
//  Copyright © 2022 Snowplow. All rights reserved.
//

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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
