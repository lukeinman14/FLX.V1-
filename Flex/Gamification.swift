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
        if let upper = current.maxNetWorth {
            let span = upper - current.minNetWorth
            let p = span > 0 ? (user.netWorthUSD - current.minNetWorth) / span : 1
            return (next, max(0, min(1, p)))
        } else {
            return (nil, 1)
        }
    }

    static let demo: GamificationModel = {
        let tiers: [Tier] = [
            // Diamond – highest tier (1M+) – bright diamond blue
            Tier(name: "Diamond", minNetWorth: 1_000_000, maxNetWorth: nil, color: Color(red: 0.70, green: 0.85, blue: 1.00)),
            // Platinum – high tier (250K - 1M) – platinum silver
            Tier(name: "Platinum", minNetWorth: 250_000, maxNetWorth: 999_999, color: Color(red: 0.85, green: 0.88, blue: 0.92)),
            // Gold – mid-high tier (100K - 250K) – rich gold
            Tier(name: "Gold", minNetWorth: 100_000, maxNetWorth: 249_999, color: Color(red: 0.98, green: 0.85, blue: 0.35)),
            // Silver – mid tier (25K - 100K) – silver gray
            Tier(name: "Silver", minNetWorth: 25_000, maxNetWorth: 99_999, color: Color(red: 0.75, green: 0.78, blue: 0.82)),
            // Bronze – entry tier (0 - 25K) – bronze brown
            Tier(name: "Bronze", minNetWorth: 0, maxNetWorth: 24_999, color: Color(red: 0.80, green: 0.50, blue: 0.20))
        ]
        return GamificationModel(tiers: tiers)
    }()
}
