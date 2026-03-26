import SwiftUI

struct EventListView: View {
    @Environment(EventStore.self) private var eventStore
    @State private var showingAddEvent = false
    @State private var editingEvent: CountdownEvent?
    @State private var searchText = ""

    var filteredEvents: [CountdownEvent] {
        let events = eventStore.events
        if searchText.isEmpty {
            return events
        }
        return events.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var pinnedEvents: [CountdownEvent] {
        filteredEvents.filter(\.isPinned).sorted { $0.date < $1.date }
    }

    var upcomingEvents: [CountdownEvent] {
        filteredEvents.filter { !$0.isPinned && !$0.isPast }.sorted { $0.date < $1.date }
    }

    var pastEvents: [CountdownEvent] {
        filteredEvents.filter { !$0.isPinned && $0.isPast }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 24) {
                        // Pinned section
                        if !pinnedEvents.isEmpty {
                            sectionHeader("📌 已置顶", count: pinnedEvents.count)
                            ForEach(pinnedEvents) { event in
                                EventRowView(event: event)
                                    .onTapGesture { editingEvent = event }
                            }
                        }

                        // Upcoming section
                        if !upcomingEvents.isEmpty {
                            sectionHeader("即将到来", count: upcomingEvents.count)
                            ForEach(upcomingEvents) { event in
                                EventRowView(event: event)
                                    .onTapGesture { editingEvent = event }
                            }
                        }

                        // Chinese holidays
                        holidaySection

                        // Past section
                        if !pastEvents.isEmpty {
                            sectionHeader("已过去", count: pastEvents.count)
                            ForEach(pastEvents) { event in
                                EventRowView(event: event)
                                    .onTapGesture { editingEvent = event }
                            }
                        }

                        // Empty state
                        if eventStore.events.isEmpty {
                            emptyState
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("倒计时")
            .searchable(text: $searchText, prompt: "搜索事件...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEditEventView(mode: .add)
            }
            .sheet(item: $editingEvent) { event in
                AddEditEventView(mode: .edit(event))
            }
        }
    }

    // MARK: - Components

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(count)个")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 80)
            Text("🕐")
                .font(.system(size: 64))
            VStack(spacing: 8) {
                Text("还没有倒计时事件")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("点击右上角 + 添加你的第一个事件")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 80)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Holiday Section

    private var upcomingHolidays: [ChineseHoliday] {
        ChineseHoliday.upcomingHolidays(limit: 5)
    }

    @ViewBuilder
    private var holidaySection: some View {
        if !upcomingHolidays.isEmpty {
            sectionHeader("🇨🇳 法定节假日", count: upcomingHolidays.count)
            ForEach(upcomingHolidays, id: \.name) { holiday in
                holidayRow(holiday)
            }
        }
    }

    private func holidayRow(_ holiday: ChineseHoliday) -> some View {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: holiday.date)).day ?? 0

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.holidayColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Text(holiday.emoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(holiday.name)
                    .font(.body)
                    .fontWeight(.medium)
                let formatter = DateFormatter()
                Text(holiday.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(days)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(days < 0 ? Color.secondary : Color.holidayColor)
                Text(days < 0 ? "天前" : "天")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.holidayColor.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            let event = holiday.toCountdownEvent()
            eventStore.add(event)
        }
    }
}
