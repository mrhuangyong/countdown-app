import Foundation

// MARK: - 中国法定节假日

struct ChineseHoliday {
    let name: String
    let date: Date
    let emoji: String

    /// 2025-2027 年中国主要节假日
    static let holidays: [ChineseHoliday] = {
        let calendar = Calendar.current
        var holidays: [ChineseHoliday] = []

        let raw: [(String, Int, Int, Int, String)] = [
            // 2025
            ("元旦", 2025, 1, 1, "🎉"),
            ("春节", 2025, 1, 29, "🧨"),
            ("清明节", 2025, 4, 4, "🌿"),
            ("劳动节", 2025, 5, 1, "⚒️"),
            ("端午节", 2025, 5, 31, "🐉"),
            ("中秋节", 2025, 10, 6, "🥮"),
            ("国庆节", 2025, 10, 1, "🇨🇳"),
            // 2026
            ("元旦", 2026, 1, 1, "🎉"),
            ("春节", 2026, 2, 17, "🧨"),
            ("清明节", 2026, 4, 5, "🌿"),
            ("劳动节", 2026, 5, 1, "⚒️"),
            ("端午节", 2026, 6, 19, "🐉"),
            ("中秋节", 2026, 9, 25, "🥮"),
            ("国庆节", 2026, 10, 1, "🇨🇳"),
            // 2027
            ("元旦", 2027, 1, 1, "🎉"),
            ("春节", 2027, 2, 6, "🧨"),
            ("清明节", 2027, 4, 5, "🌿"),
            ("劳动节", 2027, 5, 1, "⚒️"),
            ("端午节", 2027, 6, 9, "🐉"),
            ("中秋节", 2027, 9, 15, "🥮"),
            ("国庆节", 2027, 10, 1, "🇨🇳"),
        ]

        for (name, year, month, day, emoji) in raw {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            if let date = calendar.date(from: components) {
                holidays.append(ChineseHoliday(name: name, date: date, emoji: emoji))
            }
        }

        return holidays
    }()

    /// 获取即将到来的节假日（不含已过去的）
    static func upcomingHolidays(limit: Int = 10) -> [ChineseHoliday] {
        let now = Date()
        let calendar = Calendar.current
        return holidays
            .filter { calendar.compare($0.date, to: now, toGranularity: .day) != .orderedAscending }
            .prefix(limit)
            .map { $0 }
    }

    /// 转换为 CountdownEvent
    func toCountdownEvent() -> CountdownEvent {
        CountdownEvent(name: name, date: date, category: .holiday, isPinned: false)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
}
