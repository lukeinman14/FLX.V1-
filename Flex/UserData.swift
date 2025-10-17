import Foundation

/// Centralized user data manager that assigns unique net worth values to each user
/// This ensures consistency across Profile pages and Leaderboard
class UserDataManager {
    static let shared = UserDataManager()

    private init() {}

    // Map of username to net worth (in USD)
    // This would eventually be replaced with real data from Plaid
    private let userNetWorthMap: [String: Double] = [
        // Current user
        "u/You": 82_000,

        // Diamond tier users (1M+)
        "u/CryptoWhale": 2_500_000,
        "u/WhaleFin": 1_850_000,
        "u/DiamondHands": 1_200_000,

        // Platinum tier users (250K - 1M)
        "u/ByteWhale": 750_000,
        "u/QuantJunkie": 520_000,
        "u/AnonFin": 385_000,
        "u/TechBull": 290_000,

        // Gold tier users (100K - 250K)
        "u/ChipInvestor": 210_000,
        "u/ValueSeeker": 185_000,
        "u/AppleFan": 165_000,
        "u/DividendKing": 135_000,
        "u/ElonFollower": 115_000,

        // Silver tier users (25K - 100K)
        "u/TechTrader": 95_000,
        "u/EVInvestor": 78_000,
        "u/CryptoSage": 65_000,
        "u/HashHound": 52_000,
        "u/Trader123": 41_000,
        "u/StackSats": 35_000,
        "u/ByteNomad": 28_500,

        // Bronze tier users (0 - 25K)
        "u/SpiceTrader": 22_000,
        "u/Investor": 18_000,
        "u/NewbieFin": 12_000,
        "u/StartupGuy": 8_500,
        "u/LearningToTrade": 5_200,
        "u/JustStarted": 2_800
    ]

    /// Get net worth for a specific user
    func getNetWorth(for username: String) -> Double {
        return userNetWorthMap[username] ?? 0
    }

    /// Get UserProfile for a specific user
    func getUserProfile(for username: String) -> UserProfile {
        return UserProfile(
            username: username,
            netWorthUSD: getNetWorth(for: username)
        )
    }

    /// Get all users sorted by net worth (descending)
    func getAllUsersSortedByNetWorth() -> [UserProfile] {
        return userNetWorthMap.map { username, netWorth in
            UserProfile(username: username, netWorthUSD: netWorth)
        }.sorted { $0.netWorthUSD > $1.netWorthUSD }
    }

    /// Get leaderboard users for a specific tier
    func getUsersInTier(_ tier: Tier) -> [UserProfile] {
        return userNetWorthMap.compactMap { username, netWorth in
            let profile = UserProfile(username: username, netWorthUSD: netWorth)
            return tier.contains(netWorth) ? profile : nil
        }.sorted { $0.netWorthUSD > $1.netWorthUSD }
    }

    /// Format net worth as currency string
    func formatNetWorth(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            return String(format: "$%.1fM", amount / 1_000_000)
        } else if amount >= 1_000 {
            return String(format: "$%.0fK", amount / 1_000)
        } else {
            return String(format: "$%.0f", amount)
        }
    }
}
