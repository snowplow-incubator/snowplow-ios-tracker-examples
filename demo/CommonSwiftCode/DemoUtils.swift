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
    static func trackAll(_ tracker: Tracker) {
        self.trackPageViewWithTracker(tracker)
        self.trackScreenViewWithTracker(tracker)
        self.trackStructuredEventWithTracker(tracker)
        self.trackUnstructuredEventWithTracker(tracker)
        self.trackTimingWithCategoryWithTracker(tracker)
        self.trackEcommerceTransactionWithTracker(tracker)
        self.trackPushNotificationWithTracker(tracker)
    }
    
    static func trackStructuredEventWithTracker(_ tracker: Tracker) {
        let event = Structured.build({ (builder : StructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
        })
        tracker.track(event)
    }
    
    static func trackUnstructuredEventWithTracker(_ tracker: Tracker) {
        var event = Structured.build({ (builder : StructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
        })
        tracker.track(event)
        
        event = Structured.build({ (builder : StructuredBuilder?) -> Void in
            builder!.setCategory("DemoCategory")
            builder!.setAction("DemoAction")
            builder!.setLabel("DemoLabel")
            builder!.setProperty("DemoProperty")
            builder!.setValue(5)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackPageViewWithTracker(_ tracker: Tracker) {
        let data: NSDictionary = [ "targetUrl": "http://a-target-url.com"]
        let sdj = SelfDescribingJson(schema: "iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1", andData: data)!

        var event = Unstructured.build({ (builder : UnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj)
        })
        tracker.track(event)
        
        event = Unstructured.build({ (builder : UnstructuredBuilder?) -> Void in
            builder!.setEventData(sdj)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackScreenViewWithTracker(_ tracker: Tracker) {
        let screenId = UUID().uuidString
        var event = ScreenView.build({ (builder : ScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
        })
        tracker.track(event)
        
        event = ScreenView.build({ (builder : ScreenViewBuilder?) -> Void in
            builder!.setName("DemoScreenName")
            builder!.setScreenId(screenId)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackTimingWithCategoryWithTracker(_ tracker: Tracker) {
        var event = Timing.build({ (builder : TimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
        })
        tracker.track(event)
        
        event = Timing.build({ (builder : TimingBuilder?) -> Void in
            builder!.setCategory("DemoTimingCategory")
            builder!.setVariable("DemoTimingVariable")
            builder!.setTiming(5)
            builder!.setLabel("DemoTimingLabel")
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }
    
    static func trackEcommerceTransactionWithTracker(_ tracker: Tracker) {
        let transactionID = "6a8078be"
        let itemArray : [Any] = [ EcommerceItem.build({ (builder : EcommTransactionItemBuilder?) -> Void in
            builder!.setItemId(transactionID)
            builder!.setSku("DemoItemSku")
            builder!.setName("DemoItemName")
            builder!.setCategory("DemoItemCategory")
            builder!.setPrice(0.75)
            builder!.setQuantity(1)
            builder!.setCurrency("USD")
        }) ]
        
        var event = Ecommerce.build({ (builder : EcommTransactionBuilder?) -> Void in
            builder!.setOrderId(transactionID)
            builder!.setTotalValue(350)
            builder!.setAffiliation("DemoTransactionAffiliation")
            builder!.setTaxValue(10)
            builder!.setShipping(15)
            builder!.setCity("Boston")
            builder!.setState("Massachusetts")
            builder!.setCountry("USA")
            builder!.setCurrency("USD")
            builder!.setItems(itemArray)
        })
        tracker.track(event)
        
        event = Ecommerce.build({ (builder : EcommTransactionBuilder?) -> Void in
            builder!.setOrderId(transactionID)
            builder!.setTotalValue(350)
            builder!.setAffiliation("DemoTransactionAffiliation")
            builder!.setTaxValue(10)
            builder!.setShipping(15)
            builder!.setCity("Boston")
            builder!.setState("Massachusetts")
            builder!.setCountry("USA")
            builder!.setCurrency("USD")
            builder!.setItems(itemArray)
            builder!.setTimestamp(1243567890)
        })
        tracker.track(event)
    }

    static func trackPushNotificationWithTracker(_ tracker: Tracker) {
        let attachments = [["identifier": "testidentifier",
                            "url": "testurl",
                            "type": "testtype"]]

        var userInfo = Dictionary<String, Any>()
        userInfo["test"] = "test"

        let content = NotificationContent.build({(builder : NotificationContentBuilder?) -> Void in
            builder!.setTitle("title")
            builder!.setSubtitle("subtitle")
            builder!.setBody("body")
            builder!.setBadge(5)
            builder!.setSound("sound")
            builder!.setLaunchImageName("launchImageName")
            builder!.setUserInfo(userInfo)
            builder!.setAttachments(attachments)
        })

        let event = PushNotification.build({(builder : PushNotificationBuilder?) -> Void in
            builder!.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
            builder!.setAction("action")
            builder!.setDeliveryDate("date")
            builder!.setCategoryIdentifier("category")
            builder!.setThreadIdentifier("thread")
            builder!.setNotification(content)
        })

        tracker.track(event)
    }
}
