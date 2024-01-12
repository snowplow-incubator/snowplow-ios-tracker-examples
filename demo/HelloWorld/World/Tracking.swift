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
            endpoint: "https://983c-82-26-43-253.ngrok-free.app"
        ) {
            TrackerConfiguration()
                .lifecycleAutotracking(true)
        }
    }
    
    class func openWindow(windowGroupId: String) {
        if let style = windowGroups[windowGroupId] {
            let entity = WindowGroupEntity(
                windowGroupId: windowGroupId,
                windowStyle: style
            )
            let event = OpenWindowEvent()
            event.entities.append(entity)
            _ = Snowplow.defaultTracker()?.track(event)
        }
    }
    
    class func dismissWindow(windowGroupId: String) {
        if let style = windowGroups[windowGroupId] {
            let entity = WindowGroupEntity(
                windowGroupId: windowGroupId,
                windowStyle: style
            )
            let event = DismissWindowEvent()
            event.entities.append(entity)
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
