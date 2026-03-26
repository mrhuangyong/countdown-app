import Foundation
import WidgetKit

// MARK: - Event Store (UserDefaults persistence + App Group sharing)

@Observable
final class EventStore {
    var events: [CountdownEvent] {
        didSet {
            save()
            widgetCenter.reloadAllTimelines()
        }
    }

    private let defaults: UserDefaults?
    private let widgetCenter: WidgetCenter

    init() {
        self.defaults = UserDefaults(suiteName: AppConstants.suiteName)
        self.widgetCenter = WidgetCenter.shared
        self.events = []
        load()
    }

    // MARK: - CRUD

    func add(_ event: CountdownEvent) {
        events.append(event)
    }

    func update(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index] = event
        }
    }

    func delete(_ event: CountdownEvent) {
        events.removeAll { $0.id == event.id }
    }

    func delete(at indexSet: IndexSet) {
        events.remove(atOffsets: indexSet)
    }

    func move(from source: IndexSet, to destination: Int) {
        events.move(fromOffsets: source, toOffset: destination)
    }

    func togglePin(_ event: CountdownEvent) {
        if let index = events.firstIndex(where: { $0.id == event.id }) {
            events[index].isPinned.toggle()
        }
    }

    // MARK: - Sorted Events

    var pinnedEvents: [CountdownEvent] {
        events.filter(\.isPinned).sorted { $0.date < $1.date }
    }

    var upcomingEvents: [CountdownEvent] {
        events.filter { !$0.isPinned && !$0.isPast }.sorted { $0.date < $1.date }
    }

    var pastEvents: [CountdownEvent] {
        events.filter { !$0.isPinned && $0.isPast }.sorted { $0.date > $1.date }
    }

    // MARK: - Persistence

    private func save() {
        guard let defaults else { return }
        if let data = try? JSONEncoder().encode(events) {
            defaults.set(data, forKey: AppConstants.eventsKey)
        }
    }

    private func load() {
        guard let defaults,
              let data = defaults.data(forKey: AppConstants.eventsKey)
        else { return }
        events = (try? JSONDecoder().decode([CountdownEvent].self, from: data)) ?? []
    }
}
