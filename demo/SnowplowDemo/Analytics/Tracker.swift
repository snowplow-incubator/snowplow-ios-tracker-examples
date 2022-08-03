import Foundation
import SnowplowTracker

public class Tracker {
    public static let shared = Tracker()
    private let tracker: TrackerController

    init() {
        tracker = Snowplow.createTracker(namespace: "DemoAppExtensionNamespace", endpoint: "acme.fake.com", method: .post)
    }

    public func track(event: String) {
        let data = ["event": event] as NSDictionary
        guard let eventJSON = SelfDescribingJson(schema: "iglu:com.snowplowanalytics.*/*/jsonschema/1-*-*", andData: data) else {
            return
        }
        tracker.track(SelfDescribing(eventData: eventJSON))
    }
}
