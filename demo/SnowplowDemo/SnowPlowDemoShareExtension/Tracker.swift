import Foundation
import SnowplowTracker

public class Tracker {
    public static let shared = Tracker()
    private let tracker: TrackerController

    init() {
        let trackerConfig = TrackerConfiguration()
        trackerConfig.installAutotracking = false
        trackerConfig.lifecycleAutotracking = false
        trackerConfig.screenViewAutotracking = false
        tracker = Snowplow.createTracker(namespace: "DemoAppExtensionNamespace", network: NetworkConfiguration(endpoint: "acme.fake.com"), configurations: [trackerConfig])
    }

    public func trackExtensionUsage(content: String) {
        let event = Structured(category: "extension", action: content)
        tracker.track(event)
    }
}
