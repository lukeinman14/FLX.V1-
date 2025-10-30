import SwiftUI

@Observable
final class PlayerState {
    var profile: UserProfile
    var xp: Int
    var dailyStreak: Int
    var lastCheckIn: Date?
    var minTierForChat: String = "Silver" // gate chat below this tier

    init(profile: UserProfile, xp: Int = 500, dailyStreak: Int = 3, lastCheckIn: Date? = nil) {
        self.profile = profile
        self.xp = xp
        self.dailyStreak = dailyStreak
        self.lastCheckIn = lastCheckIn
    }

    func checkInToday() {
        let cal = Calendar.current
        if let last = lastCheckIn {
            if cal.isDateInYesterday(last) {
                dailyStreak += 1
                xp += 10
            } else if cal.isDateInToday(last) {
                // already checked in
            } else {
                dailyStreak = 1
                xp += 10
            }
        } else {
            dailyStreak = 1
            xp += 10
        }
        lastCheckIn = Date()
    }
}

struct XPBadge: View {
    var xp: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill").foregroundStyle(Theme.accent)
            Text("\(xp) XP").font(Theme.smallFont()).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(liquidGlassCapsule())
    }

    @ViewBuilder
    private func liquidGlassCapsule() -> some View {
        if colorScheme == .dark {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.5))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)
        } else {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.72, blue: 0.74, opacity: 0.85),
                            Color(red: 0.67, green: 0.67, blue: 0.69, opacity: 0.90),
                            Color(red: 0.64, green: 0.64, blue: 0.66, opacity: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.4))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .shadow(color: Color.white.opacity(0.4), radius: 1, x: 0, y: -1)
        }
    }
}

struct StreakBadge: View {
    var streak: Int
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill").foregroundStyle(.orange)
            Text("\(streak) day streak").font(Theme.smallFont()).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(liquidGlassCapsule())
    }

    @ViewBuilder
    private func liquidGlassCapsule() -> some View {
        if colorScheme == .dark {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.5))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)
        } else {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.72, blue: 0.74, opacity: 0.85),
                            Color(red: 0.67, green: 0.67, blue: 0.69, opacity: 0.90),
                            Color(red: 0.64, green: 0.64, blue: 0.66, opacity: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Capsule()
                        .fill(.ultraThinMaterial.opacity(0.4))
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .shadow(color: Color.white.opacity(0.4), radius: 1, x: 0, y: -1)
        }
    }
}
