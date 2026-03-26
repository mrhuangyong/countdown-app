import ActivityKit
import SwiftUI

// MARK: - Live Activity Manager

@Observable
final class LiveActivityManager {
    static let shared = LiveActivityManager()
    var currentActivity: Activity<CountdownAttributes>?

    private init() {}

    // MARK: - Start Live Activity

    @discardableResult
    func startLiveActivity(for event: CountdownEvent) -> Bool {
        // Check if ActivityKit is available
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return false
        }

        // End any existing activity
        endLiveActivity()

        let attributes = CountdownAttributes(
            eventName: event.name,
            eventEmoji: event.category.emoji,
            targetDate: event.date,
            categoryColor: event.category.hexColor,
            totalDays: event.daysRemaining
        )

        let state = CountdownAttributes.ContentState(
            eventName: event.name,
            eventEmoji: event.category.emoji,
            targetDate: event.date,
            remainingDays: event.daysRemaining,
            remainingHours: 0,
            remainingMinutes: 0,
            remainingSeconds: 0,
            isPast: event.isPast,
            categoryColor: event.category.hexColor
        )

        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
            currentActivity = activity
            return true
        } catch {
            return false
        }
    }

    // MARK: - Update Live Activity

    func updateLiveActivity(for event: CountdownEvent) {
        guard let activity = currentActivity else { return }

        let now = Date()
        let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: now, to: event.date)

        let state = CountdownAttributes.ContentState(
            eventName: event.name,
            eventEmoji: event.category.emoji,
            targetDate: event.date,
            remainingDays: max(0, components.day ?? 0),
            remainingHours: max(0, components.hour ?? 0),
            remainingMinutes: max(0, components.minute ?? 0),
            remainingSeconds: max(0, components.second ?? 0),
            isPast: event.isPast,
            categoryColor: event.category.hexColor
        )

        Task {
            await activity.update(
                ActivityContent(state: state, staleDate: nil)
            )
        }
    }

    // MARK: - End Live Activity

    func endLiveActivity() {
        let activity = currentActivity
        currentActivity = nil
        Task {
            await activity?.end(nil, dismissalPolicy: .immediate)
        }
    }

    // MARK: - Check Availability

    var isAvailable: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
}
