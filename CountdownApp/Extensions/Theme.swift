import SwiftUI

// MARK: - App-Specific Theme Colors

extension Color {
    static let accentPrimary = Color(hex: "6C5CE7")
    static let accentSecondary = Color(hex: "A29BFE")

    // MARK: - Category Colors
    static let birthdayColor = Color(hex: "FF6B6B")
    static let anniversaryColor = Color(hex: "FF85A2")
    static let examColor = Color(hex: "4ECDC4")
    static let travelColor = Color(hex: "45B7D1")
    static let holidayColor = Color(hex: "F9A825")
    static let workColor = Color(hex: "7C8CF8")
    static let customColor = Color(hex: "95A5A6")
}

// MARK: - Gradient for Categories

extension Color {
    static func categoryGradient(_ hex: String) -> LinearGradient {
        let base = Color(hex: hex)
        return LinearGradient(
            colors: [base.opacity(0.15), base.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func categoryGradient(for category: EventCategory) -> LinearGradient {
        categoryGradient(category.hexColor)
    }
}
