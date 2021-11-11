//
//  DemoUtils.m
//  SnowplowDemo
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
//  Authors: Joshua Beemster
//  Copyright: Copyright (c) 2015-2020 Snowplow Analytics Ltd
//  License: Apache License Version 2.0
//

#import "DemoUtils.h"
#import "SPPayload.h"
#import "SPSelfDescribingJson.h"
#import "SPStructured.h"
#import "SPSelfDescribing.h"
#import "SPPageView.h"
#import "SPScreenView.h"
#import "SPTiming.h"
#import "SPEcommerceItem.h"
#import "SPEcommerce.h"

@implementation DemoUtils {}

+ (int)trackAll:(id<SPTrackerController>)tracker_ {
    return [self trackStructuredEventWithTracker:tracker_]
    + [self trackUnstructuredEventWithTracker:tracker_]
    + [self trackPageViewWithTracker:tracker_]
    + [self trackScreenViewWithTracker:tracker_]
    + [self trackTimingWithCategoryWithTracker:tracker_]
    + [self trackEcommerceTransactionWithTracker:tracker_];
}

// Event Tracking

+ (int)trackStructuredEventWithTracker:(id<SPTrackerController>)tracker_ {
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"DemoCategory" action:@"DemoAction"];
    [event label:@"DemoLabel"];
    [event property:@"DemoProperty"];
    [event value:@5];
    [tracker_ track:event];
    return 1;
}

+ (int)trackUnstructuredEventWithTracker:(id<SPTrackerController>)tracker_ {
    NSDictionary * data = @{@"targetUrl": @"http://a-target-url.com"};
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1"
                                                                    andData:data];
    SPSelfDescribing *event = [[SPSelfDescribing alloc] initWithEventData:sdj];
    [tracker_ track:event];
    return 1;
}

+ (int)trackPageViewWithTracker:(id<SPTrackerController>)tracker_ {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
        [event pageTitle:@"DemoPageTitle"];
        [event referrer:@"DemoPageReferrer"];
    [tracker_ track:event];
    return 1;
}

+ (int)trackScreenViewWithTracker:(id<SPTrackerController>)tracker_ {
    NSUUID *screenId = [NSUUID UUID];
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"DemoScreenName" screenId:screenId];
    [tracker_ track:event];
    return 1;
}

+ (int)trackTimingWithCategoryWithTracker:(id<SPTrackerController>)tracker_ {
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:@5];
    [event label:@"DemoTimingLabel"];
    [tracker_ track:event];
    return 1;
}

+ (int)trackEcommerceTransactionWithTracker:(id<SPTrackerController>)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    [itemArray addObject:
     [[[[[SPEcommerceItem alloc] initWithSku:@"DemoItemSku" price:@0.75F quantity:@1]
        name:@"DemoItemName"]
       category:@"DemoItemCategory"]
      currency:@"USD"]
     ];
    
    SPEcommerce *event = [[SPEcommerce alloc] initWithOrderId:transactionID totalValue:@350 items:itemArray];
    event.affiliation = @"DemoTranAffiliation";
    event.taxValue = @10;
    event.shipping = @15;
    event.city = @"Boston";
    event.state = @"Massachusetts";
    event.country = @"USA";
    event.currency = @"USD";
    [tracker_ track:event];
    return 2;
}

@end
