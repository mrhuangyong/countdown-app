import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Live Activity Widget

@available(iOS 17.0, *)
struct CountdownLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CountdownAttributes.self) { context in
            LiveActivityView(context: context)
                .containerBackground(.fill.tertiary, for: .widget)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text(context.state.eventEmoji)
                            .font(.body)
                        Text(context.state.eventName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    .padding(.leading, 4)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    let isPast = context.state.isPast
                    let accentColor = Color.categoryColor(context.state.categoryColor)
                    Text("\(context.state.remainingDays)天")
                        .font(.system(size: UIFont.preferredFont(forTextStyle: .title2).pointSize, weight: .bold, design: .rounded))
                        .foregroundStyle(isPast ? .secondary : accentColor)
                        .padding(.trailing, 4)
                }

                DynamicIslandExpandedRegion(.center) {
                    if !context.state.isPast {
                        HStack(spacing: 2) {
                            Text(String(format: "%02d", context.state.remainingHours))
                            Text("时")
                            Text(":")
                            Text(String(format: "%02d", context.state.remainingMinutes))
                            Text("分")
                            Text(":")
                            Text(String(format: "%02d", context.state.remainingSeconds))
                            Text("秒")
                        }
                        .font(.system(.caption, design: .monospaced).weight(.semibold))
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isPast {
                        Text("已到达目标日期")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("目标：\(formattedDate(context.state.targetDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Text(context.state.eventEmoji)
            } compactTrailing: {
                Text("\(context.state.remainingDays)天")
                    .font(.caption)
                    .fontWeight(.semibold)
            } minimal: {
                Text(context.state.eventEmoji)
            }
        }
    }
}

// MARK: - Lock Screen / StandBy View

@available(iOS 17.0, *)
struct LiveActivityView: View {
    let context: ActivityViewContext<CountdownAttributes>

    private var state: CountdownAttributes.ContentState { context.state }

    private var accentColor: Color {
        Color.categoryColor(state.categoryColor)
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(state.eventEmoji)
                        .font(.title3)
                    Text(state.eventName)
                        .font(.headline)
                        .lineLimit(1)
                }

                if state.isPast {
                    Text("已到达目标日期")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if state.remainingDays > 0 {
                    Text("目标日期：\(formattedDate(state.targetDate))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("就是今天！")
                        .font(.caption)
                        .foregroundStyle(accentColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if state.isPast {
                    Text("已到达")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(state.remainingDays)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(accentColor)
                        .contentTransition(.numericText())

                    HStack(spacing: 4) {
                        Text(String(format: "%02d", state.remainingHours))
                        Text(":")
                        Text(String(format: "%02d", state.remainingMinutes))
                        Text(":")
                        Text(String(format: "%02d", state.remainingSeconds))
                    }
                    .font(.system(.caption, design: .monospaced).weight(.semibold))
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Date Formatting Helper

@available(iOS 17.0, *)
private func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "zh_CN")
    formatter.dateFormat = "M月d日"
    return formatter.string(from: date)
}
