import SwiftUI

struct EventRowView: View {
    let event: CountdownEvent
    @Environment(EventStore.self) private var eventStore
    @State private var showLiveActivity = false

    private var categoryColor: Color {
        .categoryColor(event.category.hexColor)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 52, height: 52)
                Text(event.category.emoji)
                    .font(.system(size: 24))
            }

            // Event info
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(event.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Days remaining
            VStack(alignment: .trailing, spacing: 2) {
                Text(isToday ? "今天" : "\(abs(event.daysRemaining))")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(event.isPast ? .secondary : categoryColor)
                    .contentTransition(.numericText())

                Text(isToday ? "就是今天！" : (event.isPast ? "天前" : "天"))
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
                .stroke(categoryColor.opacity(0.2), lineWidth: 1)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    eventStore.delete(event)
                    NotificationService.shared.cancelReminder(for: event.id)
                }
            } label: {
                Label("删除", systemImage: "trash")
            }

            Button {
                withAnimation {
                    eventStore.togglePin(event)
                }
            } label: {
                Label(event.isPinned ? "取消置顶" : "置顶", systemImage: event.isPinned ? "pin.slash" : "pin")
            }
            .tint(.orange)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                showLiveActivity = true
            } label: {
                Label("实时活动", systemImage: "liveactivity")
            }
            .tint(.accentPrimary)
        }
        .contextMenu {
            Button {
                withAnimation { eventStore.togglePin(event) }
            } label: {
                Label(
                    event.isPinned ? "取消置顶" : "置顶",
                    systemImage: event.isPinned ? "pin.slash" : "pin"
                )
            }

            Divider()

            Button {
                showLiveActivity = true
            } label: {
                Label("开启锁屏倒计时", systemImage: "liveactivity")
            }

            Divider()

            Button(role: .destructive) {
                withAnimation {
                    eventStore.delete(event)
                    NotificationService.shared.cancelReminder(for: event.id)
                }
            } label: {
                Label("删除", systemImage: "trash")
            }
        }
        .alert("开启锁屏实时活动？", isPresented: $showLiveActivity) {
            Button("开启") {
                LiveActivityManager.shared.startLiveActivity(for: event)
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("将在锁屏显示「\(event.name)」的实时倒计时")
        }
    }

    private var isToday: Bool {
        event.isToday
    }
}
