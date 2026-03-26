import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct EventTimelineEntry: TimelineEntry {
    let date: Date
    let events: [CountdownEvent]
    let isPreview: Bool
}

// MARK: - Timeline Provider

struct EventTimelineProvider: TimelineProvider {
    private let store = WidgetEventStore()

    func placeholder(in context: Context) -> EventTimelineEntry {
        EventTimelineEntry(
            date: Date(),
            events: [.previewBirthday, .previewTravel],
            isPreview: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (EventTimelineEntry) -> Void) {
        let events = store.loadEvents()
        let displayEvents = events.isEmpty
            ? [CountdownEvent.previewBirthday]
            : Array(events.prefix(5))
        completion(EventTimelineEntry(date: Date(), events: displayEvents, isPreview: events.isEmpty))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EventTimelineEntry>) -> Void) {
        let events = store.loadEvents()
        let displayEvents = Array(events.prefix(5))

        // Update at the start of the next day
        let calendar = Calendar.current
        let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date())

        let entry = EventTimelineEntry(date: Date(), events: displayEvents, isPreview: false)
        let timeline = Timeline(entries: [entry], policy: .after(tomorrow))
        completion(timeline)
    }
}

// MARK: - Widget Store (reads from App Group)

struct WidgetEventStore {
    func loadEvents() -> [CountdownEvent] {
        guard let defaults = UserDefaults(suiteName: AppConstants.suiteName),
              let data = defaults.data(forKey: AppConstants.eventsKey)
        else { return [] }
        return (try? JSONDecoder().decode([CountdownEvent].self, from: data)) ?? []
    }
}

// MARK: - Preview Events

extension CountdownEvent {
    static let previewBirthday = CountdownEvent(
        name: "生日派对",
        date: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
        category: .birthday
    )
    static let previewTravel = CountdownEvent(
        name: "东京旅行",
        date: Calendar.current.date(byAdding: .day, value: 42, to: Date())!,
        category: .travel
    )
    static let previewExam = CountdownEvent(
        name: "期末考试",
        date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        category: .exam
    )
}
