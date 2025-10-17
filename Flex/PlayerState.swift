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
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "bolt.fill").foregroundStyle(Theme.accent)
            Text("\(xp) XP").font(Theme.smallFont()).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Capsule().fill(Theme.surface).overlay(Capsule().stroke(Theme.divider, lineWidth: 1)))
    }
}

struct StreakBadge: View {
    var streak: Int
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill").foregroundStyle(.orange)
            Text("\(streak) day streak").font(Theme.smallFont()).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Capsule().fill(Theme.surface).overlay(Capsule().stroke(Theme.divider, lineWidth: 1)))
    }
}
