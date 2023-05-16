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

import UIKit
import AVKit
import SnowplowTracker

class PlayerViewController: AVPlayerViewController {
    
    private var tracking: MediaTracking?
    private var mediaTrackingID = "media1"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") {
            self.player = AVPlayer(url: url)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Snowplow.defaultTracker()?.media.mediaTracking(id: mediaTrackingID) == nil {
            if let player = self.player {
                let configuration = MediaTrackingConfiguration(id: mediaTrackingID)
                configuration.boundaries = [1,2,3,50,90]
                self.tracking = Snowplow.defaultTracker()?.media.startMediaTracking(
                    player: player,
                    configuration: configuration
                )
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Snowplow.defaultTracker()?.media.endMediaTracking(id: mediaTrackingID)
    }
    
}
