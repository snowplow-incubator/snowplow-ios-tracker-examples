//
//  InterfaceController.swift
//  SnowplowSwiftDemoWatch WatchKit Extension
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
//  Authors: Leo Mehlig
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

import WatchKit
import Foundation
import SnowplowTracker

class InterfaceController: WKInterfaceController, RequestCallback {
    
    let kAppId     = "DemoAppId"
    let kNamespace = "DemoAppNamespace"
    
    func getTracker(_ url: String, method: HttpMethodOptions) -> TrackerController {
        let networkConfig = NetworkConfiguration(endpoint: url, method: method)
        let emitterConfig = EmitterConfiguration()
            .byteLimitPost(52000)
            .threadPoolSize(20)
            .emitRange(500)
            .requestCallback(self)
        let trackerConfig = TrackerConfiguration()
            .appId(kAppId)
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
        let gdprConfig = GDPRConfiguration(basis: .consent, documentId: "id", documentVersion: "1.0", documentDescription: "description")
        return Snowplow.createTracker(namespace: kNamespace, network: networkConfig, configurations: [trackerConfig, emitterConfig, gdprConfig]);
    }
    
    var tracker : TrackerController!
    
    
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
            DemoUtils.trackAll(self.tracker)
        }
    }
    
    func onSuccess(withCount successCount: Int) {
        print("Success: \(successCount)")
    }
    
    func onFailure(withCount failureCount: Int, successCount: Int) {
        print("Failure: \(failureCount), Success: \(successCount)")
    }
    
}
