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
import SnowplowTracker

class PageViewController:  UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, RequestCallback {

    var tracker : TrackerController?
    var madeCounter : Int = 0
    var sentCounter : Int = 0
    var uri : String = ""
    var previousUri : String? = nil
    var methodType : HttpMethodOptions = .get
    var isRemoteConfig = false
    var token : String = ""
    @objc dynamic var snowplowId: String! = "page view"
    
    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"
    
    // Tracker setup and init
    
    func initTracker(_ url: String, method: HttpMethodOptions) -> TrackerController? {
        let network = DefaultNetworkConnection(
            urlString: url,
            httpMethod: method
        )
        network.emitThreadPoolSize = 20
        network.byteLimitPost = 52000
        let networkConfig = NetworkConfiguration(networkConnection: network)

        let trackerConfig = TrackerConfiguration()
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
            .advertisingIdentifierRetriever {
                return UUID()
            }

        let emitterConfig = EmitterConfiguration()
            .emitRange(500)
            .requestCallback(self)
            .customRetryForStatusCodes([502: false])

        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")

        let sessionConfig = SessionConfiguration(foregroundTimeoutInSeconds: 15, backgroundTimeoutInSeconds: 15)
            .onSessionStateUpdate { (session: SessionState) in
                print("SessionState: previous: \(String(describing:session.previousSessionId)) - id: \(session.sessionId) - index: \(session.sessionIndex) - userID: \(session.userId) - firstEventID: \(String(describing: session.firstEventId))")
            }
        
        let tracker = Snowplow.createTracker(namespace: kNamespace,
                                             network: networkConfig,
                                             configurations: [trackerConfig, emitterConfig, gdprConfig, sessionConfig])

        return tracker
    }
    
    func remoteTracker(_ url: String, isRefresh: Bool, callback: @escaping (TrackerController?) -> Void) {
        let remoteConfig = RemoteConfiguration(endpoint: url, method: .get)
        let successCallback: ([String]?, ConfigurationState) -> Void = { _, state in
            let tracker = Snowplow.defaultTracker()
            tracker?.emitter?.requestCallback = self
            switch state {
            case .cached:
                print("Configuration loaded from cache")
            case .fetched:
                print("Configuration downloaded from the remote endpoint")
            default:
                print("Configuration retrieved in other ways – should not happen")
            }
            callback(tracker)
        }
        if isRefresh {
            Snowplow.refresh(onSuccess: successCallback)
        } else {
            Snowplow.setup(remoteConfiguration: remoteConfig, defaultConfiguration: nil, onSuccess: successCallback)
        }
    }
    
    func updateToken(_ newToken: String) {
        token = newToken
    }

    func getCollectorUrl() -> String {
        return self.uri
    }

    func getMethodType() -> HttpMethodOptions {
        return self.methodType
    }

    func setup(callback: @escaping () -> Void) {
        if (uri.isEmpty) {
            return
        }
        if (isRemoteConfig) {
            let isRefresh = uri == previousUri
            remoteTracker(uri, isRefresh: isRefresh) { [self] trackerController in
                guard let tracker = trackerController else {
                    return
                }
                self.tracker = tracker
                self.previousUri = self.uri
                callback()
            }
        } else {
            tracker = initTracker(uri, method: methodType)
            callback()
        }
    }

    func newVc(viewController: String) -> UIViewController {
        let newViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
        (newViewController as? PageObserver)?.getParentPageViewController(parentRef: self)
        return newViewController
    }

    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "demo"),
                self.newVc(viewController: "metrics"),
                self.newVc(viewController: "web"),
                self.newVc(viewController: "player"),
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
