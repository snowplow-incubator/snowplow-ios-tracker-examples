//  Copyright (c) 2013-present Snowplow Analytics Ltd. All rights reserved.
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

import Foundation
import SnowplowTracker

class Tracking {
    
    static var windowGroups: [String : WindowStyle] = [:]
    static var immersiveSpaces: [String : ImmersionStyle] = [:]
    
    class func setup() {
        _ = Snowplow.createTracker(
            namespace: "ns",
            endpoint: "http://0.0.0.0:9090"
        ) {
            TrackerConfiguration()
                .lifecycleAutotracking(true)
        }
    }
    
    class func openWindow(windowGroupId: String) {
        if let style = windowGroups[windowGroupId] {
            let event = OpenWindowEvent(
                id: UUID(),
                stringId: windowGroupId,
                windowStyle: style
            )
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
    
    class func dismissWindow(windowGroupId: String) {
        if let style = windowGroups[windowGroupId] {
            let event = DismissWindowEvent(
                id: UUID(),
                stringId: windowGroupId,
                windowStyle: style
            )
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
    
    class func openImmersiveSpace(immersiveSpaceId: String) {
        if let style = immersiveSpaces[immersiveSpaceId] {
            let entity = ImmersiveSpaceEntity(
                immersiveSpaceId: immersiveSpaceId,
                immersionStyle: style
            )
            let event = OpenImmersiveSpaceEvent()
            event.entities.append(entity)
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
    
    class func dismissImmersiveSpace(immersiveSpaceId: String) {
        if let style = immersiveSpaces[immersiveSpaceId] {
            let entity = ImmersiveSpaceEntity(
                immersiveSpaceId: immersiveSpaceId,
                immersionStyle: style
            )
            let event = DismissImmersiveSpaceEvent()
            event.entities.append(entity)
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
}
