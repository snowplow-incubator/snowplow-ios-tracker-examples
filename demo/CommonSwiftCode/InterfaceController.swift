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

import WatchKit
import Foundation
import SnowplowTracker

class InterfaceController: WKInterfaceController, RequestCallback {
    
    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"
    
    func getTracker(_ url: String, method: HttpMethodOptions) -> TrackerController? {
        let networkConfig = NetworkConfiguration(endpoint: url, method: method)
        let emitterConfig = EmitterConfiguration()
        emitterConfig.byteLimitPost = 52000
        emitterConfig.threadPoolSize = 20
        emitterConfig.emitRange = 500
        emitterConfig.requestCallback = self
        let trackerConfig = TrackerConfiguration()
        trackerConfig.appId = kAppId
        trackerConfig.base64Encoding = false
        trackerConfig.sessionContext = true
        trackerConfig.platformContext = true
        trackerConfig.geoLocationContext = false
        trackerConfig.lifecycleAutotracking = true
        trackerConfig.screenViewAutotracking = true
        trackerConfig.screenContext = true
        trackerConfig.applicationContext = true
        trackerConfig.exceptionAutotracking = true
        trackerConfig.installAutotracking = true
        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        return Snowplow.createTracker(namespace: kNamespace, network: networkConfig, configurations: [trackerConfig, emitterConfig, gdprConfig]);
    }
    
    var tracker : TrackerController?
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.tracker = self.getTracker("http://acme.fake.com", method: .get)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func sendEvent() {
        DispatchQueue.global(qos: .default).async {
            // Track all types of events
            if let tracker = self.tracker {
                DemoUtils.trackAll(tracker)
            }
        }
    }
    
    func onSuccess(withCount successCount: Int) {
        print("Success: \(successCount)")
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        print("Failure: \(failureCount), Success: \(successCount)")
    }
    
}
