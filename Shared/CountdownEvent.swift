import Foundation

// MARK: - Event Category

enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case birthday = "birthday"
    case anniversary = "anniversary"
    case exam = "exam"
    case travel = "travel"
    case holiday = "holiday"
    case work = "work"
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .birthday: return "生日"
        case .anniversary: return "纪念日"
        case .exam: return "考试"
        case .travel: return "旅行"
        case .holiday: return "节日"
        case .work: return "工作"
        case .custom: return "自定义"
        }
    }

    var emoji: String {
        switch self {
        case .birthday: return "🎂"
        case .anniversary: return "💕"
        case .exam: return "📝"
        case .travel: return "✈️"
        case .holiday: return "🎉"
        case .work: return "💼"
        case .custom: return "⭐"
        }
    }

    var hexColor: String {
        switch self {
        case .birthday: return "FF6B6B"
        case .anniversary: return "FF85A2"
        case .exam: return "4ECDC4"
        case .travel: return "45B7D1"
        case .holiday: return "F9A825"
        case .work: return "7C8CF8"
        case .custom: return "95A5A6"
        }
    }
}

enum EventSourceType: String, Codable, CaseIterable {
    case local
    case systemCalendar
}

// MARK: - Countdown Event

struct CountdownEvent: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var date: Date
    var category: EventCategory
    var isPinned: Bool
    var createdAt: Date
    var remindDaysBefore: Int
    var sourceType: EventSourceType
    var externalCalendarId: String?
    var externalEventId: String?
    var externalLastModifiedDate: Date?

    var daysRemaining: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
    }

    var isPast: Bool {
        daysRemaining < 0
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }

    var relativeDateString: String {
        if isToday {
            return "就是今天！"
        } else if isPast {
            return "已过去 \(abs(daysRemaining)) 天"
        } else if daysRemaining == 1 {
            return "明天"
        } else {
            return "还有 \(daysRemaining) 天"
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        category: EventCategory = .custom,
        isPinned: Bool = false,
        createdAt: Date = Date(),
        remindDaysBefore: Int = 0,
        sourceType: EventSourceType = .local,
        externalCalendarId: String? = nil,
        externalEventId: String? = nil,
        externalLastModifiedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.category = category
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.remindDaysBefore = remindDaysBefore
        self.sourceType = sourceType
        self.externalCalendarId = externalCalendarId
        self.externalEventId = externalEventId
        self.externalLastModifiedDate = externalLastModifiedDate
    }
}
