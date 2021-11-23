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
    static func trackAll(_ tracker: TrackerController) -> Int {
        return self.trackStructuredEventWithTracker(tracker)
        + self.trackSelfDescribingEventWithTracker(tracker)
        + self.trackScreenViewWithTracker(tracker)
        + self.trackTimingWithCategoryWithTracker(tracker)
        + self.trackEcommerceTransactionWithTracker(tracker)
        + self.trackDeepLinkReceivedWithTracker(tracker)
        + self.trackMessageNotificationWithTracker(tracker)
    }
    
    static func trackStructuredEventWithTracker(_ tracker: TrackerController) -> Int {
        let event = Structured(category: "DemoCategory", action: "DemoAction")
            .label("DemoLabel")
            .property("DemoProperty much longer than the expected value.")
            .value(5)
        tracker.track(event)
        return 1
    }
    
    static func trackSelfDescribingEventWithTracker(_ tracker: TrackerController) -> Int {
        let data = ["targetUrl": "http://a-target-url.com" as NSObject];
        let event = SelfDescribing(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", payload: data)
        tracker.track(event)
        return 1
    }
    
    static func trackScreenViewWithTracker(_ tracker: TrackerController) -> Int {
        let event = ScreenView(name: "DemoScreenName", screenId: UUID())
        tracker.track(event)
        return 1
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: TrackerController) -> Int {
        let event = Timing(category: "DemoTimingCategory", variable: "DemoTimingVariable", timing: 5)
            .label("DemoTimingLabel")
        tracker.track(event)
        return 1
    }
    
    static func trackEcommerceTransactionWithTracker(_ tracker: TrackerController) -> Int {
        let transactionID = "6a8078be"
        
        let itemArray = [
            EcommerceItem(sku: "DemoItemSku", price: 0.75, quantity: 1)
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
    
    static func trackDeepLinkReceivedWithTracker(_ tracker: TrackerController) -> Int {
        let event = DeepLinkReceived(url: "https://snowplowanalytics.com")
            .referrer("https://snowplowanalytics.com/referrer")
        tracker.track(event)
        return 1
    }
    
    static func trackMessageNotificationWithTracker(_ tracker: TrackerController) -> Int {
        let event = MessageNotification(title: "title", body: "body", trigger: .push)
            .notificationTimestamp("2021-10-18T10:16:08.008Z")
            .action("action")
            .bodyLocKey("loc key")
            .bodyLocArgs(["loc arg1", "loc arg2"])
            .sound("chime.mp3")
            .notificationCount(9)
            .category("category1")
            .attachments([
                MessageNotificationAttachment(identifier: "id", type: "type", url: "https://snowplowanalytics.com")
            ]);
        tracker.track(event)
        return 1
    }
}
