//
//  ViewController.m
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

#import "ViewController.h"
#import "DemoUtils.h"
#import <SnowplowTracker/SnowplowTracker-umbrella.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *            madeLabel;
@property (nonatomic, weak) IBOutlet UILabel *            dbCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isRunningLabel;
@property (nonatomic, weak) IBOutlet UILabel *            sentCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            sessionCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *            isBackgroundLabel;
@property (nonatomic, weak) IBOutlet UITextField *        urlTextField;
@property (nonatomic, weak) IBOutlet UISegmentedControl * methodType;
@property (nonatomic, weak) IBOutlet UISegmentedControl * trackingOnOff;
@property (nonatomic, weak) IBOutlet UISegmentedControl * protocolType;
@property (strong, nonatomic) IBOutlet UIScrollView *     scrollView;

@end

@implementation ViewController {
    id<SPTrackerController> _tracker;
    long long int     _madeCounter;
    long long int     _sentCounter;
    NSTimer *         _updateTimer;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setup {
    _tracker = [self trackerWithUrl:@"http://acme.fake.com" method:SPHttpMethodPost];
    _updateTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateMetrics) userInfo:nil repeats:YES];
    _urlTextField.delegate = self;
    [_trackingOnOff addTarget:self
                       action:@selector(action)
             forControlEvents:UIControlEventValueChanged];
}

- (IBAction) trackEvents:(id)sender {
    NSString *prefix = [self getProtocolType] == SPProtocolHttp ? @"http://" : @"https://";
    NSString *url = [NSString stringWithFormat:@"%@%@", prefix, [self getCollectorUrl]];
    SPHttpMethod methodType = [self getMethodType];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([url isEqual: @""]) {
            return;
        }
        
        // Update the Tracker
        
        // Ensures the application won't crash with a bad URL
        @try {
            self->_tracker.network.endpoint = url;
            self->_tracker.network.method = methodType;
        }
        @catch (NSException *exception) {
            return;
        }
        
        // Track all types of events and update count of total number of tracked events
        self->_madeCounter += [DemoUtils trackAll:self->_tracker];
    });
}

- (void) updateMetrics {
    [_madeLabel setText:[NSString stringWithFormat:@"Made: %lld", _madeCounter]];
    [_dbCountLabel setText:[NSString stringWithFormat:@"DB Count: %lu", (unsigned long)_tracker.emitter.dbCount]];
    [_sessionCountLabel setText:[NSString stringWithFormat:@"Session Count: %lu", (unsigned long)_tracker.session.sessionIndex]];
    [_isRunningLabel setText:[NSString stringWithFormat:@"Running: %s", _tracker.emitter.isSending ? "yes" : "no"]];
    [_isBackgroundLabel setText:[NSString stringWithFormat:@"Background: %s", _tracker.session.isInBackground ? "yes" : "no"]];
    [_sentCountLabel setText:[NSString stringWithFormat:@"Sent: %lu", (unsigned long)_sentCounter]];
}

- (void) action {
    BOOL tracking = _trackingOnOff.selectedSegmentIndex == 0 ? YES : NO;
    if (!tracking && _tracker.isTracking) {
        [_tracker pause];
    } else if (tracking && !_tracker.isTracking) {
        [_tracker resume];
    }
}

- (NSString *) getCollectorUrl {
    return _urlTextField.text;
}

- (enum SPHttpMethod) getMethodType {
    return _methodType.selectedSegmentIndex == 0 ? SPHttpMethodGet : SPHttpMethodPost;
}

- (enum SPProtocol) getProtocolType {
    return _protocolType.selectedSegmentIndex == 0 ? SPProtocolHttp : SPProtocolHttps;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

static NSString *const kAppId     = @"DemoAppId";
static NSString *const kNamespace = @"DemoAppNamespace";

// Tracker Setup & Init

- (id<SPTrackerController>)trackerWithUrl:(NSString *)url method:(enum SPHttpMethod)method {
    SPNetworkConfiguration *network = [[SPNetworkConfiguration alloc] initWithEndpoint:url method:method];
    network.requestHeaders = @{@"x": @"y"};
    SPEmitterConfiguration *emitter = [[SPEmitterConfiguration alloc] init];
    emitter.emitRange = 500;
    emitter.threadPoolSize = 20;
    emitter.byteLimitPost = 52000;
    SPTrackerConfiguration *tracker = [[SPTrackerConfiguration alloc] init];
    tracker.platformContext = YES;
    tracker.geoLocationContext = YES;
    tracker.appId = kAppId;
    tracker.base64Encoding = YES;
    tracker.sessionContext = YES;
    SPGlobalContextsConfiguration *globalContexts = [[SPGlobalContextsConfiguration alloc] init];
    globalContexts.contextGenerators = @{
        @"rulesetExampleTag": [self rulesetGlobalContextExample],
        @"staticExampleTag": [self staticGlobalContextExample],
    }.mutableCopy;
    return [SPSnowplow createTrackerWithNamespace:kNamespace network:network configurations:@[emitter, tracker, globalContexts]];
}

- (SPGlobalContext *)rulesetGlobalContextExample {
    SPSchemaRuleset *schemaRuleset = [[SPSchemaRuleset alloc] initWithAllowedList:@[@"iglu:com.snowplowanalytics.*/*/jsonschema/1-*-*"]
                                                                    andDeniedList:@[@"iglu:com.snowplowanalytics.mobile/*/jsonschema/1-*-*"]];
    return [[SPGlobalContext alloc] initWithGenerator:^NSArray<SPSelfDescribingJson *> *(id<SPInspectableEvent> event) {
        return @[
            [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0" andData:@{@"key": @"rulesetExample"}],
            [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0" andData:@{@"eventName": event.schema}],
        ];
    } ruleset:schemaRuleset];
}

- (SPGlobalContext *)staticGlobalContextExample {
    return [[SPGlobalContext alloc] initWithStaticContexts:@[
        [[SPSelfDescribingJson alloc] initWithSchema:@"iglu:com.snowplowanalytics.iglu/anything-a/jsonschema/1-0-0" andData:@{@"key": @"staticExample"}],
    ]];
}

// Define Callback Functions

- (void) onSuccessWithCount:(NSInteger)successCount {
    _sentCounter += successCount;
}

- (void) onFailureWithCount:(NSInteger)failureCount successCount:(NSInteger)successCount {
    _sentCounter += successCount;
}

@end
