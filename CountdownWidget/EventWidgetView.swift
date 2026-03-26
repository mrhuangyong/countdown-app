import WidgetKit
import SwiftUI

// MARK: - Widget Configuration

struct CountdownEventWidget: Widget {
    let kind = "CountdownEventWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EventTimelineProvider()) { entry in
            EventWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(UIColor.systemGroupedBackground)
                }
        }
        .configurationDisplayName("事件倒计时")
        .description("在桌面显示你的倒计时事件")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular
        ])
    }
}

// MARK: - Entry View

struct EventWidgetEntryView: View {
    let entry: EventTimelineEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        case .accessoryRectangular:
            rectangularWidget
        default:
            smallWidget
        }
    }

    // MARK: - Small Widget

    @ViewBuilder
    private var smallWidget: some View {
        if let event = entry.events.first {
            VStack(spacing: 8) {
                Text(event.category.emoji)
                    .font(.title2)

                VStack(spacing: 2) {
                    Text(event.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    Text("\(abs(event.daysRemaining))天")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(event.isPast ? .secondary : Color.categoryColor(event.category.hexColor))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Medium Widget

    @ViewBuilder
    private var mediumWidget: some View {
        if let event = entry.events.first {
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(event.category.emoji)
                        .font(.system(size: 36))

                    Text(event.category.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(event.name)
                        .font(.headline)
                        .lineLimit(1)

                    Text(event.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(event.isPast ? "已过去" : "还有")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(spacing: 2) {
                    Text("\(abs(event.daysRemaining))")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(event.isPast ? .secondary : Color.categoryColor(event.category.hexColor))
                    Text("天")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }

    // MARK: - Large Widget

    @ViewBuilder
    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("倒计时")
                .font(.headline)
                .foregroundStyle(.secondary)

            ForEach(entry.events.prefix(4)) { event in
                HStack(spacing: 12) {
                    Text(event.category.emoji)
                        .font(.title3)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(event.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        Text(event.formattedDate)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(event.isPast ? "\(abs(event.daysRemaining))天前" : "\(event.daysRemaining)天")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(event.isPast ? .secondary : Color.categoryColor(event.category.hexColor))
                }
                .padding(.vertical, 4)

                if event.id != entry.events.prefix(4).last?.id {
                    Divider()
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
    }

    // MARK: - Rectangular Widget (Lock Screen)

    @ViewBuilder
    private var rectangularWidget: some View {
        if let event = entry.events.first {
            HStack(spacing: 8) {
                Text(event.category.emoji)

                VStack(alignment: .leading, spacing: 1) {
                    Text(event.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    Text(event.isPast ? "\(abs(event.daysRemaining))天前" : "\(event.daysRemaining)天")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    CountdownEventWidget()
} timeline: {
    EventTimelineEntry(date: Date(), events: [.previewBirthday, .previewTravel], isPreview: false)
}

#Preview(as: .systemMedium) {
    CountdownEventWidget()
} timeline: {
    EventTimelineEntry(date: Date(), events: [.previewBirthday, .previewTravel, .previewExam], isPreview: false)
}
