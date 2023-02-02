//  Copyright (c) 2015-2020 Snowplow Analytics Ltd. All rights reserved.
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
import Foundation
import CoreData
import SnowplowTracker

// Used for all child views
protocol PageObserver: AnyObject {
    func getParentPageViewController(parentRef: PageViewController)
}

class DemoViewController: UIViewController, UITextFieldDelegate, PageObserver {
    private let keyUriField = "URL-Endpoint";

    @IBOutlet weak var uriField: UITextField!
    @IBOutlet weak var configSwitch: UISegmentedControl!
    @IBOutlet weak var trackingSwitch: UISegmentedControl!
    @IBOutlet weak var methodSwitch: UISegmentedControl!
    @IBOutlet weak var setupConfigBtn: UIButton!
    
    var tracker : TrackerController? {
        let t: TrackerController? = parentPageViewController.tracker
        return t
    }

    var parentPageViewController: PageViewController!
    @objc dynamic var snowplowId: String! = "demo view"

    func getParentPageViewController(parentRef: PageViewController) {
        parentPageViewController = parentRef
    }

    @objc func action() {
        let tracking: Bool = (trackingSwitch.selectedSegmentIndex == 0)
        if (tracking && !(tracker?.isTracking ?? false)) {
            tracker?.resume()
        } else if (tracker?.isTracking ?? false) {
            tracker?.pause()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.parentPageViewController.uri = uriField.text!
        return textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uriField.delegate = self
        self.trackingSwitch.addTarget(self, action: #selector(action), for: .valueChanged)
        // Do any additional setup after loading the view, typically from a nib.
        uriField.text = UserDefaults.standard.string(forKey: keyUriField) ?? ""
        inputUri(uriField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func inputUri(_ sender: UITextField) {
        self.parentPageViewController.uri = uriField.text!
    }
    
    @IBAction func toggleMethod(_ sender: UISegmentedControl) {
        self.parentPageViewController.methodType = (methodSwitch.selectedSegmentIndex == 0) ?
            .get : .post
    }
    
    @IBAction func configSwitchChanged(_ sender: UISegmentedControl) {
        let isRemote = (sender.selectedSegmentIndex == 0)
        self.parentPageViewController.isRemoteConfig = isRemote
    }
    
    @IBAction func trackEvents(_ sender: UIButton) {
        guard let tracker = self.tracker else {
            return
        }
        // Track all types of events and increase number of tracked events
        let eventsTracked = DemoUtils.trackAll(tracker)
        self.parentPageViewController.madeCounter += eventsTracked
        showToast(message: "\(eventsTracked) events tracked")
    }
    
    @IBAction func setupConfigBtnAction(_ sender: UIButton) {
        UserDefaults.standard.set(uriField.text ?? "", forKey: keyUriField);
        self.parentPageViewController.setup {
            DispatchQueue.main.async {
                self.showToast(message: "Tracker config updated")
            }
        }
    }
    
    // Toast message
    
    private func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: 10, y: self.view.frame.size.height-100, width: self.view.frame.size.width-20, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}
