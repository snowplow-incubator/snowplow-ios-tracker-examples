//
//  DemoUtils.swift
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

import Foundation
import SnowplowTracker

class DemoUtils {
    static func trackAll(_ tracker: TrackerControlling) -> Int {
        return self.trackStructuredEventWithTracker(tracker)
        + self.trackUnstructuredEventWithTracker(tracker)
        + self.trackScreenViewWithTracker(tracker)
        + self.trackTimingWithCategoryWithTracker(tracker)
        + self.trackEcommerceTransactionWithTracker(tracker)
        + self.trackPushNotificationWithTracker(tracker)
    }
    
    static func trackStructuredEventWithTracker(_ tracker: TrackerControlling) -> Int {
        let event = Structured(category: "DemoCategory", action: "DemoAction")
            .label("DemoLabel")
            .property("DemoProperty")
            .value(5)
        tracker.track(event)
        return 1
    }
    
    static func trackUnstructuredEventWithTracker(_ tracker: TrackerControlling) -> Int {
        let data = ["targetUrl": "http://a-target-url.com"];
        let sdj = SelfDescribingJson(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", andData: data as NSObject)!
        let event = Unstructured(eventData: sdj)
        tracker.track(event)
        return 1
    }
    
    static func trackScreenViewWithTracker(_ tracker: TrackerControlling) -> Int {
        let event = ScreenView(name: "DemoScreenName", screenId: UUID())
        tracker.track(event)
        return 1
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: TrackerControlling) -> Int {
        let event = Timing(category: "DemoTimingCategory", variable: "DemoTimingVariable", timing: 5)
            .label("DemoTimingLabel")
        tracker.track(event)
        return 1
    }
    
    static func trackEcommerceTransactionWithTracker(_ tracker: TrackerControlling) -> Int {
        let transactionID = "6a8078be"
        
        let itemArray = [
            EcommerceItem(itemId: transactionID, sku: "DemoItemSku", price: 0.75, quantity: 1)
                .name("DemoItemName")
                .category("DemoItemCategory")
                .currency("USD")
        ]
        
        let event = Ecommerce(orderId: transactionID, totalValue: 350, items: itemArray)
            .affiliation("DemoTransactionAffiliation")
            .taxValue(10)
            .shipping(15)
            .city("Boston")
            .state("Massachisetts")
            .country("USA")
            .currency("USD")

        tracker.track(event)
        return 2
    }

    static func trackPushNotificationWithTracker(_ tracker: TrackerControlling) -> Int {
        let attachments = [["identifier": "testidentifier",
                            "url": "testurl",
                            "type": "testtype"]]

        var userInfo = Dictionary<String, Any>()
        userInfo["test"] = "test"

        let content = NotificationContent(title: "title", body: "body", badge: 5)
            .subtitle("subtitle")
            .sound("sound")
            .launchImageName("launchImageName")
            .userInfo(userInfo)
            .attachments(attachments)
        
        let event = PushNotification(
            date: "date",
            action: "action",
            trigger: "PUSH",
            category: "category",
            thread: "thread",
            notification: content)

        tracker.track(event)
        return 1
    }
}
