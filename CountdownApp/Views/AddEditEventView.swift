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
