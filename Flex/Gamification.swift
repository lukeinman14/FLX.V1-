import SwiftUI

struct Tier: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let minNetWorth: Double // inclusive, in USD
    let maxNetWorth: Double? // nil means no upper bound
    let color: Color

    var rangeDescription: String {
        if let max = maxNetWorth {
            return "$\(format(minNetWorth)) – $\(format(max))"
        } else {
            return "$\(format(minNetWorth))+"
        }
    }

    func contains(_ netWorth: Double) -> Bool {
        if let max = maxNetWorth { return netWorth >= minNetWorth && netWorth <= max }
        return netWorth >= minNetWorth
    }

    private func format(_ v: Double) -> String {
        if v >= 1_000_000 { return String(format: "%.0fM", v/1_000_000) }
        if v >= 1_000 { return String(format: "%.0fk", v/1_000) }
        return String(Int(v))
    }
}

struct UserProfile {
    var username: String
    var netWorthUSD: Double
}

struct GamificationModel {
    let tiers: [Tier]

    func currentTier(for user: UserProfile) -> Tier? {
        tiers.first { $0.contains(user.netWorthUSD) }
    }

    func nextTierProgress(for user: UserProfile) -> (next: Tier?, progress: Double) {
        // progress is 0..1 toward the next tier
        guard let currentIndex = tiers.firstIndex(where: { $0.contains(user.netWorthUSD) }) else {
            // below first tier
            if let first = tiers.first {
                let progress = max(0, min(1, user.netWorthUSD / max(first.minNetWorth, 1)))
                return (first, progress)
            }
            return (nil, 0)
        }
        let current = tiers[currentIndex]
        let next = currentIndex + 1 < tiers.count ? tiers[currentIndex + 1] : nil
        if let max = current.maxNetWorth {
            let span = max - current.minNetWorth
            let p = span > 0 ? (user.netWorthUSD - current.minNetWorth) / span : 1
            return (next, max(0, min(1, p)))
        } else {
            return (nil, 1)
        }
    }

    static let demo: GamificationModel = {
        let tiers: [Tier] = [
            Tier(name: "Bronze", minNetWorth: 0, maxNetWorth: 5_000, color: Theme.accentMuted.opacity(0.6)),
            Tier(name: "Silver", minNetWorth: 5_001, maxNetWorth: 10_000, color: Theme.accentMuted.opacity(0.7)),
            Tier(name: "Gold", minNetWorth: 10_001, maxNetWorth: 25_000, color: Theme.accentMuted.opacity(0.85)),
            Tier(name: "Platinum", minNetWorth: 25_001, maxNetWorth: 100_000, color: Theme.accentMuted),
            Tier(name: "Diamond", minNetWorth: 100_001, maxNetWorth: nil, color: Theme.accent)
        ]
        return GamificationModel(tiers: tiers)
    }()
}
