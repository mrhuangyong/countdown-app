import ActivityKit
import Foundation

// MARK: - Live Activity Attributes

struct CountdownAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        // Dynamic data that updates during the Live Activity
        var eventName: String
        var eventEmoji: String
        var targetDate: Date
        var remainingDays: Int
        var remainingHours: Int
        var remainingMinutes: Int
        var remainingSeconds: Int
        var isPast: Bool
        var categoryColor: String
    }

    // Static data set when the Live Activity starts
    var eventName: String
    var eventEmoji: String
    var targetDate: Date
    var categoryColor: String
    var totalDays: Int
}

// MARK: - App Group Constants

enum AppConstants {
    static let appGroupId = "group.com.openclaw.countdown"
    static let suiteName = "group.com.openclaw.countdown"
    static let eventsKey = "countdown_events"
    static let liveActivityToggleKey = "live_activity_enabled"
}
