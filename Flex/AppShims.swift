import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
// MARK: - Theme adapter to FlexTheme

struct FlexTheme {
    #if canImport(UIKit)
    static let bg = Color(UIColor.systemBackground)
    static let card = Color(UIColor.secondarySystemBackground)
    static let line = Color(UIColor.separator)
    #elseif canImport(AppKit)
    static let bg = Color(nsColor: .windowBackgroundColor)
    static let card = Color(nsColor: .underPageBackgroundColor)
    static let line = Color(nsColor: .separatorColor)
    #else
    static let bg = Color(.sRGB, red: 0.05, green: 0.05, blue: 0.05, opacity: 1)
    static let card = Color(.sRGB, red: 0.09, green: 0.09, blue: 0.09, opacity: 1)
    static let line = Color(.sRGB, red: 0.2, green: 0.2, blue: 0.2, opacity: 1)
    #endif
    static let accent = Color.accentColor
    static let secondary = Color.gray
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    struct Fonts {
        static let title: Font = .system(size: 22, weight: .bold, design: .rounded)
        static let body: Font = .system(size: 17, weight: .regular, design: .rounded)
    }
}

enum Shim {
    struct Theme {
        static let bg: Color = FlexTheme.bg
        static let surface: Color = FlexTheme.card
        static let surfaceElevated: Color = FlexTheme.card
        static let divider: Color = FlexTheme.line
        static let accent: Color = FlexTheme.accent
        static let accentMuted: Color = FlexTheme.secondary
        static let textPrimary: Color = FlexTheme.textPrimary
        static let textSecondary: Color = FlexTheme.textSecondary

        static func headingFont() -> Font { FlexTheme.Fonts.title }
        static func bodyFont() -> Font { FlexTheme.Fonts.body }
        static func smallFont() -> Font { .system(size: 13, weight: .regular, design: .rounded) }
    }

    struct TabSelectionKey: EnvironmentKey { static let defaultValue: Binding<Int>? = nil }

}

extension EnvironmentValues {
    var shimTabSelection: Binding<Int>? {
        get { self[Shim.TabSelectionKey.self] }
        set { self[Shim.TabSelectionKey.self] = newValue }
    }
}

