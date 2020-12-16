//
//  PageViewController.swift
//  SnowplowSwiftDemo
//
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
//
//  Authors: Michael Hadam
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

import UIKit
import SnowplowTracker

class PageViewController:  UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, RequestCallback {

    var tracker : TrackerControlling!
    var madeCounter : Int = 0
    var sentCounter : Int = 0
    var uri : String = ""
    var methodType : RequestOptions = .get
    var protocolType : ProtocolOptions = .http
    var token : String = ""
    @objc dynamic var snowplowId: String! = "page view"

    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"

    // Tracker setup and init

    func getTracker(_ url: String, method: RequestOptions) -> TrackerControlling {
        let eventStore = SQLiteEventStore();
        let network = DefaultNetworkConnection.build { (builder) in
            builder.setUrlEndpoint(url)
            builder.setHttpMethod(method)
            builder.setEmitThreadPoolSize(20)
            builder.setByteLimitPost(52000)
        }
        let networkConfig = NetworkConfiguration(endpoint: url, protocol: .https, method: method)
        let trackerConfig = TrackerConfiguration(namespace: kNamespace, appId: kAppId)
            .base64Encoding(false)
            .sessionContext(true)
            .platformContext(true)
            .geoLocationContext(false)
            .lifecycleAutotracking(true)
            .screenViewAutotracking(true)
            .screenContext(true)
            .applicationContext(true)
            .exceptionAutotracking(true)
            .installAutotracking(true)
            .diagnosticAutotracking(true)
            .logLevel(.verbose)
            .loggerDelegate(self)
        let emitterConfig = EmitterConfiguration()
            .networkConnection(network)
            .eventStore(eventStore)
            .emitRange(500)
            .requestCallback(self)
        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        let gcConfig = GlobalContextsConfiguration()
        gcConfig.add(tag: "ruleSetExampleTag", contextGenerator: ruleSetGlobalContextExample())
        gcConfig.add(tag: "staticExampleTag", contextGenerator: staticGlobalContextExample())
        
        return Tracker.setup(network: networkConfig, tracker: trackerConfig, configurations: [emitterConfig, gdprConfig, gcConfig]);
    }
    
    func ruleSetGlobalContextExample() -> GlobalContext {
        let schemaRuleset = SchemaRuleset(allowedList: ["iglu:com.snowplowanalytics.*/*/jsonschema/1-*-*"],
                                            andDeniedList: ["iglu:com.snowplowanalytics.mobile/*/jsonschema/1-*-*"])
        return GlobalContext(generator: { event -> [SelfDescribingJson]? in
            return [
                SelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["key": "rulesetExample"] as NSObject),
                SelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["eventName": event.schema] as NSObject)
            ]
        }, ruleset: schemaRuleset)
    }
    
    func staticGlobalContextExample() -> GlobalContext {
        return GlobalContext(staticContexts: [
            SelfDescribingJson.init(schema: "iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0", andData: ["key": "staticExample"] as NSObject),
        ])
    }

    func updateToken(_ newToken: String) {
        token = newToken
    }

    func getCollectorUrl() -> String {
        return self.uri
    }

    func getMethodType() -> RequestOptions {
        return self.methodType
    }

    func getProtocolType() -> ProtocolOptions {
        return self.protocolType
    }
    
    func setup() {
        self.tracker = self.getTracker("acme.fake.com", method: .post)
    }

    func newVc(viewController: String) -> UIViewController {
        let newViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        (newViewController as? PageObserver)?.getParentPageViewController(parentRef: self)
        return newViewController
    }

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "demo"),
                self.newVc(viewController: "metrics"),
                self.newVc(viewController: "additional")]
    }()

    // MARK: Data source functions.
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllers.count > previousIndex else {
            return nil
        }

        return orderedViewControllers[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }

        guard orderedViewControllersCount > nextIndex else {
            return nil
        }

        return orderedViewControllers[nextIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.setup()
        // This sets up the first view that will show up on our page control
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    func onSuccess(withCount successCount: Int) {
        self.sentCounter += successCount;
    }

    func onFailure(withCount failureCount: Int, successCount: Int) {
        self.sentCounter += successCount;
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

extension PageViewController: LoggerDelegate {
    func error(_ tag: String, message: String) {
        print("[Error] \(tag): \(message)")
    }
    
    func debug(_ tag: String, message: String) {
        print("[Debug] \(tag): \(message)")
    }
    
    func verbose(_ tag: String, message: String) {
        print("[Verbose] \(tag): \(message)")
    }
}
