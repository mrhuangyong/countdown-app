import UIKit
import SwiftUI

struct SettingsView: View {
    @Environment(EventStore.self) private var eventStore
    @AppStorage("sortOrder") private var sortOrder: SortOrder = .date
    @AppStorage("showPastEvents") private var showPastEvents = true

    enum SortOrder: String, CaseIterable {
        case date = "date"
        case name = "name"
        case created = "created"

        var displayName: String {
            switch self {
            case .date: return "按日期"
            case .name: return "按名称"
            case .created: return "按创建时间"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                Form {
                    // Display settings
                    Section {
                        Picker("排序方式", selection: $sortOrder) {
                            ForEach(SortOrder.allCases, id: \.self) { order in
                                Text(order.displayName).tag(order)
                            }
                        }

                        Toggle("显示已过去的事件", isOn: $showPastEvents)
                    } header: {
                        Text("显示")
                    }

                    // Notifications
                    Section {
                        Button("打开通知设置") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    } header: {
                        Text("通知")
                    } footer: {
                        Text("在系统设置中管理通知权限")
                    }

                    // Data
                    Section {
                        Button("清除所有事件", role: .destructive) {
                            clearAllEvents()
                        }
                    } header: {
                        Text("数据")
                    } footer: {
                        Text("当前共有 \(eventStore.events.count) 个事件")
                    }

                    // About
                    Section {
                        LabeledContent("版本", value: "1.0.0")
                        LabeledContent("构建", value: "1")
                    } header: {
                        Text("关于")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }

    private func clearAllEvents() {
        eventStore.events.removeAll()
        NotificationService.shared.cancelAllReminders()
        LiveActivityManager.shared.endLiveActivity()
    }
}
