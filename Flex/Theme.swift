import SwiftUI

enum Theme {
    static let bg = Color(red: 0.03, green: 0.08, blue: 0.07)
    static let surface = Color(red: 0.05, green: 0.12, blue: 0.10)
    static let surfaceElevated = Color(red: 0.06, green: 0.15, blue: 0.12)
    static let accent = Color(red: 0.53, green: 0.95, blue: 0.83)
    static let accentMuted = Color(red: 0.40, green: 0.85, blue: 0.77)
    static let textPrimary = Color(red: 0.78, green: 0.95, blue: 0.90)
    static let textSecondary = Color(red: 0.52, green: 0.77, blue: 0.72)
    static let divider = Color(red: 0.10, green: 0.22, blue: 0.19).opacity(0.7)

    static func titleFont() -> Font { .system(size: 28, weight: .semibold, design: .rounded) }
    static func headingFont() -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func bodyFont() -> Font { .system(size: 18, weight: .regular, design: .rounded) }
    static func smallFont() -> Font { .system(size: 14, weight: .regular, design: .rounded) }
}

struct NeonStyle: ViewModifier {
    var foreground: Color = Theme.textPrimary
    func body(content: Content) -> some View {
        content
            .foregroundStyle(foreground)
            .shadow(color: Theme.accent.opacity(0.08), radius: 0, x: 0, y: 1)
    }
}

extension View {
    func neon(_ color: Color = Theme.textPrimary) -> some View {
        modifier(NeonStyle(foreground: color))
    }
}

extension String {
    /// Removes the "u/" prefix from usernames for display
    var withoutUsernamePrefix: String {
        self.replacingOccurrences(of: "u/", with: "")
    }

    /// Ensures username has "u/" prefix for internal use
    var withUsernamePrefix: String {
        self.hasPrefix("u/") ? self : "u/\(self)"
    }
}
