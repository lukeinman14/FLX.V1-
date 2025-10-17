import SwiftUI

// MARK: - Theme adapter to FlexTheme

struct FlexTheme {
    static let bg = Color(.systemBackground)
    static let card = Color(.secondarySystemBackground)
    static let line = Color(.separator)
    static let accent = Color.accentColor
    static let secondary = Color.gray
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    
    struct Fonts {
        static let title: Font = .system(size: 22, weight: .bold, design: .rounded)
        static let body: Font = .system(size: 17, weight: .regular, design: .rounded)
    }
}

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

// MARK: - Models needed by LeaderboardView 2.swift

struct UserProfile {
    var username: String
    var netWorthUSD: Double
}

struct Tier: Identifiable {
    let id = UUID()
    let name: String
    let minNetWorth: Double
    let maxNetWorth: Double?
    let color: Color
    
    var rangeDescription: String {
        if let max = maxNetWorth {
            return "$\(Int(minNetWorth)) - $\(Int(max))"
        } else {
            return "$\(Int(minNetWorth))+"
        }
    }
    
    func contains(_ worth: Double) -> Bool {
        worth >= minNetWorth && (maxNetWorth == nil || worth <= maxNetWorth!)
    }
}

struct GamificationModel {
    let tiers: [Tier]
    
    func currentTier(for user: UserProfile) -> Tier? {
        tiers.first(where: { $0.contains(user.netWorthUSD) })
    }
    
    func nextTierProgress(for user: UserProfile) -> (next: Tier?, progress: Double) {
        guard let idx = tiers.firstIndex(where: { $0.contains(user.netWorthUSD) }) else {
            // unranked, progress toward first tier
            guard let first = tiers.first else { return (nil, 0) }
            let progress = min(max(user.netWorthUSD / max(first.minNetWorth, 1), 0), 1)
            return (first, progress)
        }
        if idx == tiers.count - 1 {
            return (nil, 1)
        }
        let current = tiers[idx]
        let next = tiers[idx + 1]
        let span = max((next.minNetWorth - current.minNetWorth), 1)
        let progress = min(max((user.netWorthUSD - current.minNetWorth) / span, 0), 1)
        return (next, progress)
    }
    
    static var demo: GamificationModel {
        GamificationModel(tiers: [
            Tier(name: "Bronze", minNetWorth: 0, maxNetWorth: 5_000, color: .brown),
            Tier(name: "Silver", minNetWorth: 5_000, maxNetWorth: 25_000, color: .gray),
            Tier(name: "Gold", minNetWorth: 25_000, maxNetWorth: 100_000, color: .yellow),
            Tier(name: "Platinum", minNetWorth: 100_000, maxNetWorth: 1_000_000, color: .cyan),
            Tier(name: "Diamond", minNetWorth: 1_000_000, maxNetWorth: nil, color: .mint)
        ])
    }
}

// MARK: - Minimal ProfileView to satisfy NavigationLink destinations

struct ProfileView: View {
    let username: String
    let accent: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 64))
                .foregroundStyle(accent)
            Text(username)
                .font(Theme.headingFont())
                .foregroundStyle(Theme.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
        .navigationTitle("Profile")
    }
}

// MARK: - Environment key for tabSelection used in LeaderboardView 2.swift

private struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<Int>? = nil
}

extension EnvironmentValues {
    var tabSelection: Binding<Int>? {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}
