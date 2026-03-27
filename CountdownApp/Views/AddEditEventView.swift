import SwiftUI

enum EventFormMode {
    case add
    case edit(CountdownEvent)
}

struct AddEditEventView: View {
    let mode: EventFormMode
    @Environment(EventStore.self) private var eventStore
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var date = Date()
    @State private var category: EventCategory = .custom
    @State private var remindDaysBefore: Int = 0
    @State private var enableReminder = false
    @State private var showingCalendarImport = false
    @State private var importedCount = 0

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var existingEvent: CountdownEvent? {
        if case .edit(let event) = mode { return event }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                Form {
                    // Event Name
                    Section {
                        TextField("事件名称", text: $name)
                    } header: {
                        Text("名称")
                    }

                    // Date
                    Section {
                        DatePicker(
                            "日期",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                        .frame(maxWidth: .infinity)
                    } header: {
                        Text("日期")
                    }

                    // Category
                    Section {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                            ForEach(EventCategory.allCases) { cat in
                                CategoryPickerItem(
                                    category: cat,
                                    isSelected: category == cat
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        category = cat
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("分类")
                    }

                    // Reminder
                    Section {
                        Toggle("开启提醒", isOn: $enableReminder)

                        if enableReminder {
                            Stepper(
                                "提前 \(remindDaysBefore) 天提醒",
                                value: $remindDaysBefore,
                                in: 1...30
                            )
                        }
                    } header: {
                        Text("提醒")
                    } footer: {
                        if enableReminder {
                            Text("将在事件前 \(remindDaysBefore) 天发送通知提醒")
                        }
                    }

                    Section {
                        Button {
                            showingCalendarImport = true
                        } label: {
                            Label("从系统日历导入", systemImage: "calendar.badge.plus")
                        }
                    } header: {
                        Text("日历")
                    } footer: {
                        if importedCount > 0 {
                            Text("刚刚已导入 \(importedCount) 个事件")
                        } else {
                            Text("支持批量导入未来 1 年内的系统日历事件")
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "编辑事件" : "添加事件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let event = existingEvent {
                    name = event.name
                    date = event.date
                    category = event.category
                    remindDaysBefore = event.remindDaysBefore
                    enableReminder = event.remindDaysBefore > 0
                }
            }
            .sheet(isPresented: $showingCalendarImport) {
                CalendarImportSheet { importedEvents in
                    eventStore.importEvents(importedEvents)
                    importedCount = importedEvents.count
                    for event in importedEvents where event.remindDaysBefore > 0 {
                        NotificationService.shared.scheduleReminder(for: event)
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        if let existing = existingEvent {
            var updated = existing
            updated.name = trimmedName
            updated.date = date
            updated.category = category
            updated.remindDaysBefore = enableReminder ? remindDaysBefore : 0
            eventStore.update(updated)
            NotificationService.shared.scheduleReminder(for: updated)
        } else {
            let event = CountdownEvent(
                name: trimmedName,
                date: date,
                category: category,
                remindDaysBefore: enableReminder ? remindDaysBefore : 0
            )
            eventStore.add(event)
            NotificationService.shared.scheduleReminder(for: event)
        }

        dismiss()
    }
}

struct CalendarImportSheet: View {
    @Environment(CalendarService.self) private var calendarService
    @Environment(\.dismiss) private var dismiss

    @State private var events: [CalendarImportItem] = []
    @State private var selectedIds = Set<String>()
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var didDenyAccess = false

    let onImport: ([CountdownEvent]) -> Void

    private var filteredEvents: [CalendarImportItem] {
        guard !searchText.isEmpty else { return events }
        return events.filter { item in
            item.title.localizedCaseInsensitiveContains(searchText) ||
            item.calendarTitle.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if didDenyAccess {
                    ContentUnavailableView("未获得日历权限", systemImage: "calendar.badge.exclamationmark", description: Text("请在系统设置中开启日历权限后重试"))
                } else if isLoading {
                    ProgressView("正在读取系统日历…")
                } else if filteredEvents.isEmpty {
                    ContentUnavailableView("暂无可导入事件", systemImage: "calendar")
                } else {
                    List(filteredEvents, id: \.id) { item in
                        Button {
                            toggleSelection(for: item.id)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: selectedIds.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedIds.contains(item.id) ? .accent : .secondary)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    Text("\(item.calendarTitle) · \(item.startDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("导入系统日历")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("导入") {
                        let selected = events.filter { selectedIds.contains($0.id) }
                        let mapped = selected.map { $0.toCountdownEvent() }
                        onImport(mapped)
                        dismiss()
                    }
                    .disabled(selectedIds.isEmpty)
                }
            }
            .searchable(text: $searchText, prompt: "搜索日历事件")
            .task {
                await loadEvents()
            }
        }
    }

    private func loadEvents() async {
        isLoading = true
        let loaded = await calendarService.fetchUpcomingEvents(days: 365)
        didDenyAccess = loaded.isEmpty && calendarService.accessState == .denied
        events = loaded
        isLoading = false
    }

    private func toggleSelection(for id: String) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}

// MARK: - Category Picker Item

struct CategoryPickerItem: View {
    let category: EventCategory
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.categoryColor(category.hexColor).opacity(0.2) : Color(.systemGray5))
                    .frame(height: 56)
                Text(category.emoji)
                    .font(.system(size: 24))
            }

            Text(category.displayName)
                .font(.caption2)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.categoryColor(category.hexColor) : .secondary)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.categoryColor(category.hexColor) : .clear, lineWidth: 2)
        )
    }
}
