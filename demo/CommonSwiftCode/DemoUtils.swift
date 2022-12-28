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
        event.label = "DemoLabel"
        event.property = "DemoProperty much longer than the expected value."
        event.value = 5
        _ = tracker.track(event)
        return 1
    }
    
    static func trackSelfDescribingEventWithTracker(_ tracker: TrackerController) -> Int {
        let data = ["targetUrl": "http://a-target-url.com"];
        let event = SelfDescribing(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", payload: data)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackScreenViewWithTracker(_ tracker: TrackerController) -> Int {
        let event = ScreenView(name: "DemoScreenName", screenId: UUID())
        _ = tracker.track(event)
        return 1
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: TrackerController) -> Int {
        let event = Timing(category: "DemoTimingCategory", variable: "DemoTimingVariable", timing: 5)
        event.label = "DemoTimingLabel"
        _ = tracker.track(event)
        return 1
    }
    
    static func trackEcommerceTransactionWithTracker(_ tracker: TrackerController) -> Int {
        let transactionID = "6a8078be"
        
        let item = EcommerceItem(sku: "DemoItemSku", price: 0.75, quantity: 1)
        item.name = "DemoItemName"
        item.category = "DemoItemCategory"
        item.currency = "USD"
        
        let event = Ecommerce(orderId: transactionID, totalValue: 350, items: [item])
        event.affiliation = "DemoTransactionAffiliation"
        event.taxValue = 10
        event.shipping = 15
        event.city = "Boston"
        event.state = "Massachisetts"
        event.country = "USA"
        event.currency = "USD"

        _ = tracker.track(event)
        return 2
    }
    
    static func trackDeepLinkReceivedWithTracker(_ tracker: TrackerController) -> Int {
        let event = DeepLinkReceived(url: "https://snowplowanalytics.com")
        event.referrer = "https://snowplowanalytics.com/referrer"
        _ = tracker.track(event)
        return 1
    }
    
    static func trackMessageNotificationWithTracker(_ tracker: TrackerController) -> Int {
        let event = MessageNotification(title: "title", body: "body", trigger: .push)
        event.notificationTimestamp = "2021-10-18T10:16:08.008Z"
        event.action = "action"
        event.bodyLocKey = "loc key"
        event.bodyLocArgs = ["loc arg1", "loc arg2"]
        event.sound = "chime.mp3"
        event.notificationCount = 9
        event.category = "category1"
        event.attachments = [
            MessageNotificationAttachment(identifier: "id", type: "type", url: "https://snowplowanalytics.com")
        ]
        _ = tracker.track(event)
        return 1
    }
}
