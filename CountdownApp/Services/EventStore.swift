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
        else {
            loadSampleEvents()
            return
        }
        events = (try? JSONDecoder().decode([CountdownEvent].self, from: data)) ?? []
        if events.isEmpty {
            loadSampleEvents()
        }
    }

    private func loadSampleEvents() {
        let calendar = Calendar.current
        let now = Date()
        var components = DateComponents()

        // 新年倒计时
        components.year = 2027; components.month = 1; components.day = 1
        let newYear = calendar.date(from: components) ?? now

        // 春节
        components.year = 2027; components.month = 2; components.day = 6
        let springFestival = calendar.date(from: components) ?? now

        // 7天后
        let in7Days = calendar.date(byAdding: .day, value: 7, to: now)!

        // 30天后
        let in30Days = calendar.date(byAdding: .day, value: 30, to: now)!

        // 3个月前
        let ago90Days = calendar.date(byAdding: .day, value: -90, to: now)!

        events = [
            CountdownEvent(name: "2027 新年", date: newYear, category: .holiday, isPinned: true),
            CountdownEvent(name: "春节", date: springFestival, category: .holiday, isPinned: true),
            CountdownEvent(name: "周末旅行", date: in7Days, category: .travel),
            CountdownEvent(name: "项目交付", date: in30Days, category: .work),
            CountdownEvent(name: "朋友生日", date: ago90Days, category: .birthday),
        ]
        save()
    }
}
