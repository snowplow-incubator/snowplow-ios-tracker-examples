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
#import "SPTracker.h"
#import "SPSelfDescribingJson.h"
#import "SPEvent.h"

@implementation DemoUtils {}

+ (int)trackAll:(SPTracker *)tracker_ {
    return [self trackStructuredEventWithTracker:tracker_]
    + [self trackUnstructuredEventWithTracker:tracker_]
    + [self trackPageViewWithTracker:tracker_]
    + [self trackScreenViewWithTracker:tracker_]
    + [self trackTimingWithCategoryWithTracker:tracker_]
    + [self trackEcommerceTransactionWithTracker:tracker_]
    + [self trackPushNotificationWithTracker:tracker_];
}

// Event Tracking

+ (int)trackStructuredEventWithTracker:(SPTracker *)tracker_ {
    SPStructured *event = [[SPStructured alloc] initWithCategory:@"DemoCategory" action:@"DemoAction"];
    [event label:@"DemoLabel"];
    [event property:@"DemoProperty"];
    [event value:@5];
    [tracker_ track:event];
    return 1;
}

+ (int)trackUnstructuredEventWithTracker:(SPTracker *)tracker_ {
    NSDictionary * data = @{@"targetUrl": @"http://a-target-url.com"};
    SPSelfDescribingJson * sdj = [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.snowplow/link_click/jsonschema/1-0-1"
                                                                    andData:data];
    SPUnstructured *event = [[SPUnstructured alloc] initWithEventData:sdj];
    [tracker_ track:event];
    return 1;
}

+ (int)trackPageViewWithTracker:(SPTracker *)tracker_ {
    SPPageView *event = [[SPPageView alloc] initWithPageUrl:@"DemoPageUrl"];
        [event pageTitle:@"DemoPageTitle"];
        [event referrer:@"DemoPageReferrer"];
    [tracker_ track:event];
    return 1;
}

+ (int)trackScreenViewWithTracker:(SPTracker *)tracker_ {
    NSUUID *screenId = [NSUUID UUID];
    SPScreenView *event = [[SPScreenView alloc] initWithName:@"DemoScreenName" screenId:screenId];
    [tracker_ track:event];
    return 1;
}

+ (int)trackTimingWithCategoryWithTracker:(SPTracker *)tracker_ {
    SPTiming *event = [[SPTiming alloc] initWithCategory:@"DemoTimingCategory" variable:@"DemoTimingVariable" timing:@5];
    [event label:@"DemoTimingLabel"];
    [tracker_ track:event];
    return 1;
}

+ (int)trackEcommerceTransactionWithTracker:(SPTracker *)tracker_ {
    NSString *transactionID = @"6a8078be";
    NSMutableArray *itemArray = [NSMutableArray array];
    
    [itemArray addObject:
     [[[[[SPEcommerceItem alloc] initWithItemId:transactionID sku:@"DemoItemSku" price:@0.75F quantity:@1]
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

+ (int)trackPushNotificationWithTracker:(SPTracker *)tracker_ {
    NSMutableArray * attachments = [[NSMutableArray alloc] init];
    [attachments addObject:@{ @"identifier" : @"testidentifier",
                              @"url" : @"testurl",
                              @"type" : @"testtype"
                              }];

    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"test" forKey:@"test"];
    
    SPNotificationContent * content = [[SPNotificationContent alloc] initWithTitle:@"title" body:@"body" badge:@5];
    content.subtitle = @"subtitle";
    content.sound = @"sound";
    content.launchImageName = @"launchImageName";
    content.userInfo = userInfo.copy;
    content.attachments = attachments.copy;

    SPPushNotification * event = [[SPPushNotification alloc] initWithDate:@"date"
                                                                   action:@"action"
                                                                  trigger:@"PUSH"
                                                                 category:@"category"
                                                                   thread:@"thread"
                                                             notification:content];
    [tracker_ track:event];
    return 1;
}

@end
