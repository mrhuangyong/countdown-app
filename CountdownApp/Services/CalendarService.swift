import Foundation
import EventKit
import Observation

struct CalendarImportItem: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let calendarId: String
    let calendarTitle: String
    let lastModifiedDate: Date?

    init(event: EKEvent) {
        self.id = event.eventIdentifier ?? UUID().uuidString
        self.title = event.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? (event.title ?? "未命名事件") : "未命名事件"
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.calendarId = event.calendar.calendarIdentifier
        self.calendarTitle = event.calendar.title
        self.lastModifiedDate = event.lastModifiedDate
    }

    func toCountdownEvent(defaultReminderDays: Int = 0) -> CountdownEvent {
        CountdownEvent(
            name: title,
            date: startDate,
            category: .custom,
            remindDaysBefore: defaultReminderDays,
            sourceType: .systemCalendar,
            externalCalendarId: calendarId,
            externalEventId: id,
            externalLastModifiedDate: lastModifiedDate
        )
    }
}

@MainActor
@Observable
final class CalendarService {
    static let shared = CalendarService()

    enum AccessState: Equatable {
        case unknown
        case granted
        case denied
    }

    private let eventStore = EKEventStore()
    private(set) var accessState: AccessState = .unknown

    private init() {
        refreshAuthorizationStatus()
    }

    func refreshAuthorizationStatus() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .fullAccess, .writeOnly:
            accessState = .granted
        case .denied, .restricted:
            accessState = .denied
        case .notDetermined:
            accessState = .unknown
        @unknown default:
            accessState = .denied
        }
    }

    @discardableResult
    func requestAccessIfNeeded() async -> Bool {
        refreshAuthorizationStatus()
        guard accessState != .granted else { return true }

        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            refreshAuthorizationStatus()
            return granted
        } catch {
            accessState = .denied
            return false
        }
    }

    func fetchUpcomingEvents(days: Int = 365) async -> [CalendarImportItem] {
        let granted = await requestAccessIfNeeded()
        guard granted else { return [] }

        let now = Date()
        guard let endDate = Calendar.current.date(byAdding: .day, value: days, to: now) else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: now, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .filter { $0.eventIdentifier != nil }

        return events.compactMap { event in
            guard event.eventIdentifier != nil else { return nil }
            return CalendarImportItem(event: event)
        }
    }
}
