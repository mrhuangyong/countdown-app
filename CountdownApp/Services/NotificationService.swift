import UserNotifications

// MARK: - Notification Service

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: - Schedule

    func scheduleReminder(for event: CountdownEvent) {
        cancelReminder(for: event.id)

        guard event.remindDaysBefore > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(event.category.emoji) \(event.name)"
        content.body = event.remindDaysBefore == 1
            ? "明天就是\(event.name)了！"
            : "距离\(event.name)还有 \(event.remindDaysBefore) 天"
        content.sound = .default

        guard let reminderDate = Calendar.current.date(
            byAdding: .day,
            value: -event.remindDaysBefore,
            to: event.date
        ) else { return }

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error { print("Failed to schedule notification: \(error.localizedDescription)") }
        }
    }

    // MARK: - Cancel

    func cancelReminder(for eventId: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventId.uuidString])
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
