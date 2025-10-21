import SwiftUI

enum Theme {
    // Dynamic colors that adapt to dark/light mode
    static var bg: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.03, green: 0.08, blue: 0.07)  // Dark mode (current)
            : Color(red: 0.94, green: 0.94, blue: 0.96)   // Light mode (slightly darker off-white for glass contrast)
    }

    static var surface: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.05, green: 0.12, blue: 0.10)   // Dark mode (current)
            : Color.white.opacity(0.7)                     // Light mode (translucent white for glass)
    }

    static var surfaceElevated: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.06, green: 0.15, blue: 0.12)   // Dark mode (current)
            : Color.white.opacity(0.85)                    // Light mode (more opaque glass)
    }

    static var accent: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.53, green: 0.95, blue: 0.83)   // Dark mode (current teal)
            : Color(red: 0.18, green: 0.50, blue: 0.22)   // Light mode (darker forest green)
    }

    static var accentMuted: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.40, green: 0.85, blue: 0.77)   // Dark mode (current)
            : Color(red: 0.18, green: 0.50, blue: 0.22)   // Light mode (darker forest green)
    }

    static var textPrimary: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.78, green: 0.95, blue: 0.90)   // Dark mode (current)
            : Color(red: 0.1, green: 0.1, blue: 0.1)      // Light mode (near black)
    }

    static var textSecondary: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.52, green: 0.77, blue: 0.72)   // Dark mode (current)
            : Color(red: 0.35, green: 0.35, blue: 0.35)   // Light mode (dark grey)
    }

    static var divider: Color {
        AppSettings.shared.isDarkMode
            ? Color(red: 0.10, green: 0.22, blue: 0.19).opacity(0.7)  // Dark mode (current)
            : Color.gray.opacity(0.2)                                  // Light mode (subtle gray)
    }

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

// MARK: - Liquid Glass Effect (Light Mode)
struct GlassEffect: ViewModifier {
    var radius: CGFloat = 20
    var material: Material = .ultraThinMaterial

    func body(content: Content) -> some View {
        if AppSettings.shared.isDarkMode {
            // Dark mode: No glass effect, just content
            content
        } else {
            // Light mode: Apple-style Liquid Glass
            content
                .background(
                    RoundedRectangle(cornerRadius: radius)
                        .fill(material)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: radius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
        }
    }
}

extension View {
    func liquidGlass(radius: CGFloat = 20, material: Material = .ultraThinMaterial) -> some View {
        modifier(GlassEffect(radius: radius, material: material))
    }
}
