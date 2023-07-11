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

import Foundation
import SnowplowTracker

class DemoUtils {
    static func trackAll(_ tracker: TrackerController) -> Int {
        return self.trackStructuredEventWithTracker(tracker)
        + self.trackSelfDescribingEventWithTracker(tracker)
        + self.trackScreenViewWithTracker(tracker)
        + self.trackTimingWithCategoryWithTracker(tracker)
        + self.trackDeepLinkReceivedWithTracker(tracker)
        + self.trackMessageNotificationWithTracker(tracker)
        + self.trackAddToCartWithTracker(tracker)
        + self.trackCheckoutStepWithTracker(tracker)
        + self.trackProductListClickWithTracker(tracker)
        + self.trackProductListViewWithTracker(tracker)
        + self.trackProductViewWithTracker(tracker)
        + self.trackPromoClickWithTracker(tracker)
        + self.trackPromoViewWithTracker(tracker)
        + self.trackRefundWithTracker(tracker)
        + self.trackRemoveFromCartWithTracker(tracker)
        + self.trackTransactionWithTracker(tracker)
        + self.trackTransactionErrorWithTracker(tracker)
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
    
    static func trackAddToCartWithTracker(_ tracker: TrackerController) -> Int {
        let product = ProductEntity(id: "productId", category: "product/category", currency: "NZD", price: 3)
        let anotherProduct = ProductEntity(id: "productId2", category: "product/category/specific", currency: "NZD", price: 100)
        
        let cart = CartEntity(totalValue: 5, currency: "NZD")
        
        let event = AddToCartEvent(products: [product, anotherProduct], cart: cart)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackCheckoutStepWithTracker(_ tracker: TrackerController) -> Int {
        let event = CheckoutStepEvent(step: 1, accountType: "guest")
        _ = tracker.track(event)
        return 1
    }
    
    static func trackProductListClickWithTracker(_ tracker: TrackerController) -> Int {
        if let price = Decimal(string: "1234567.89") {
            let product = ProductEntity(id: "ABC", category: "category", currency: "KRW", price: price)
            
            let event = ProductListClickEvent(product: product)
            _ = tracker.track(event)
            return 1
        }
        return 0
    }
    
    static func trackProductListViewWithTracker(_ tracker: TrackerController) -> Int {
        let product = ProductEntity(id: "plow1", category: "snow.clearance.ploughs.large", currency: "NOK", price: 3000)
        
        let event = ProductListViewEvent(products: [product], name: "listName")
        _ = tracker.track(event)
        return 1
    }
    
    static func trackProductViewWithTracker(_ tracker: TrackerController) -> Int {
        let product = ProductEntity(id: "plow2", category: "snow.clearance.ploughs.large", currency: "NOK", price: 5000)
        
        let event = ProductViewEvent(product: product)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackPromoClickWithTracker(_ tracker: TrackerController) -> Int {
        let promotion = PromotionEntity(id: "XYZ-promo")
        
        let event = PromotionClickEvent(promotion: promotion)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackPromoViewWithTracker(_ tracker: TrackerController) -> Int {
        let promotion = PromotionEntity(id: "ABC-promo")
        
        let event = PromotionViewEvent(promotion: promotion)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackRefundWithTracker(_ tracker: TrackerController) -> Int {
        let event = RefundEvent(transactionId: "sale567", refundAmount: 555, currency: "HKD")
        _ = tracker.track(event)
        return 1
    }
    
    static func trackRemoveFromCartWithTracker(_ tracker: TrackerController) -> Int {
        if let price = Decimal(string: "1.99") {
            let product = ProductEntity(id: "1234abc567-1", category: "iap/boost", currency: "EUR", price: price)
            
            let cart = CartEntity(totalValue: 4, currency: "EUR")
            
            let event = RemoveFromCartEvent(products: [product], cart: cart)
            _ = tracker.track(event)
            return 1
        }
        return 0
    }
    
    static func trackTransactionWithTracker(_ tracker: TrackerController) -> Int {
        let transaction = TransactionEntity(transactionId: "sale567", revenue: 1000, currency: "HKD", paymentMethod: "paypal", totalQuantity: 2)
        let event = TransactionEvent(transaction: transaction)
        _ = tracker.track(event)
        return 1
    }
    
    static func trackTransactionErrorWithTracker(_ tracker: TrackerController) -> Int {
        let transaction = TransactionEntity(transactionId: "saleABC", revenue: 9001, currency: "GBP", paymentMethod: "visa", totalQuantity: 1)
        let event = TransactionErrorEvent(transaction: transaction, errorCode: "error", errorType: .soft)
        _ = tracker.track(event)
        return 1
    }
}
