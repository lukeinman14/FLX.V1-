import SwiftUI

/// Helper to generate unique avatar styles for different users
struct AvatarHelper {

    /// Returns a unique avatar view for a given username
    /// Every user gets assigned one and only one punk image based on their username
    static func avatarView(for username: String, size: CGFloat = 40) -> some View {
        let imageName = getPunkImageName(for: username)

        return Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    /// Returns SF Symbol-based avatar for a given username
    static func symbolAvatarView(for username: String, size: CGFloat = 40) -> some View {
        let avatar = getAvatarStyle(for: username)

        return Image(systemName: avatar.symbol)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(
                LinearGradient(
                    colors: avatar.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    // MARK: - Private Helpers

    /// Maps username to punk image asset name
    private static func getPunkImageName(for username: String) -> String {
        // Predefined mapping for known users
        let imageMap: [String: String] = [
            "u/You": "punk-you",
            "u/CryptoWhale": "punk-cryptowhale",
            "u/ByteWhale": "punk-bytewhale",
            "u/QuantJunkie": "punk-quantjunkie",
            "u/MoonTrader": "punk-moontrader",
            "u/TechBull": "punk-techbull",
            "u/DiamondHands": "punk-diamondhands",
            "u/AnonFin": "punk-anonfin",
            "u/ByteNomad": "punk-bytenomad",
            "u/SpiceTrader": "punk-spicetrader",
            "u/AlgoKing": "punk-algoking",
            "u/ValueInvestor": "punk-valueinvestor",
            "u/WSBDegenerate": "punk-wsbdegenerate",
            "u/DeFiNinja": "punk-definininja",
            "u/SwingMaster": "punk-swingmaster",
            "u/BearGang": "punk-beargang",
            "u/DividendDaddy": "punk-dividenddaddy",
            "u/NFTCollector": "punk-nftcollector",
            "u/MacroTrader": "punk-macrotrader",
            "u/PennyStockPro": "punk-pennystockpro",
            "u/CryptoMiner": "punk-cryptominer",
            "u/ThetaGang": "punk-thetagang",
            "u/GrowthHacker": "punk-growthhacker",
            "u/RealEstateBull": "punk-realestatebull",
            "u/ForexTrader": "punk-forextrader"
        ]

        // If user has a predefined punk, return it
        if let punkImage = imageMap[username] {
            return punkImage
        }

        // For unmapped users, deterministically assign a unique punk based on username hash
        // All available punk images in the asset folder
        let allPunkImages = [
            "punk-you",
            "punk-cryptowhale",
            "punk-bytewhale",
            "punk-quantjunkie",
            "punk-moontrader",
            "punk-techbull",
            "punk-diamondhands",
            "punk-anonfin",
            "punk-bytenomad",
            "punk-spicetrader",
            "punk-algoking",
            "punk-valueinvestor",
            "punk-wsbdegenerate",
            "punk-definininja",
            "punk-swingmaster",
            "punk-beargang",
            "punk-dividenddaddy",
            "punk-nftcollector",
            "punk-macrotrader",
            "punk-pennystockpro",
            "punk-cryptominer",
            "punk-thetagang",
            "punk-growthhacker",
            "punk-realestatebull",
            "punk-forextrader"
        ]

        // Use deterministic hash function based on username characters
        // This ensures the same username ALWAYS gets the same punk image
        let punkIndex = deterministicHash(for: username) % allPunkImages.count
        return allPunkImages[punkIndex]
    }

    /// Creates a deterministic hash from a username string
    /// Unlike Swift's hashValue, this will always return the same value for the same input
    private static func deterministicHash(for string: String) -> Int {
        var hash = 0
        for char in string.unicodeScalars {
            hash = (hash &* 31) &+ Int(char.value)
        }
        return abs(hash)
    }

    private struct AvatarStyle {
        let emoji: String
        let symbol: String
        let gradientColors: [Color]
    }

    private static func getAvatarStyle(for username: String) -> AvatarStyle {
        // Map usernames to specific avatar styles (CryptoPunk-inspired)
        let avatarMap: [String: AvatarStyle] = [
            "u/CryptoWhale": AvatarStyle(
                emoji: "🐋",
                symbol: "bitcoinsign.circle.fill",
                gradientColors: [.blue, .cyan, .teal]
            ),
            "u/ByteWhale": AvatarStyle(
                emoji: "🤖",
                symbol: "cpu.fill",
                gradientColors: [.purple, .blue, .indigo]
            ),
            "u/QuantJunkie": AvatarStyle(
                emoji: "📊",
                symbol: "chart.line.uptrend.xyaxis",
                gradientColors: [.green, .mint, .cyan]
            ),
            "u/MoonTrader": AvatarStyle(
                emoji: "🌙",
                symbol: "moonphase.full.moon",
                gradientColors: [.yellow, .orange, .red]
            ),
            "u/TechBull": AvatarStyle(
                emoji: "🐂",
                symbol: "bolt.fill",
                gradientColors: [.red, .orange, .yellow]
            ),
            "u/DiamondHands": AvatarStyle(
                emoji: "💎",
                symbol: "diamond.fill",
                gradientColors: [.cyan, .blue, .purple]
            ),
            "u/AnonFin": AvatarStyle(
                emoji: "🥷",
                symbol: "person.fill.questionmark",
                gradientColors: [.gray, .secondary, .primary]
            ),
            "u/ByteNomad": AvatarStyle(
                emoji: "🌍",
                symbol: "airplane.circle.fill",
                gradientColors: [.green, .blue, .cyan]
            ),
            "u/SpiceTrader": AvatarStyle(
                emoji: "🌶️",
                symbol: "flame.fill",
                gradientColors: [.red, .orange, .pink]
            ),
            "u/AlgoKing": AvatarStyle(
                emoji: "👑",
                symbol: "crown.fill",
                gradientColors: [.yellow, .orange, .red]
            ),
            "u/ValueInvestor": AvatarStyle(
                emoji: "🎯",
                symbol: "target",
                gradientColors: [.blue, .indigo, .purple]
            ),
            "u/WSBDegenerate": AvatarStyle(
                emoji: "🎰",
                symbol: "dice.fill",
                gradientColors: [.red, .pink, .purple]
            ),
            "u/DeFiNinja": AvatarStyle(
                emoji: "🥷",
                symbol: "lock.shield.fill",
                gradientColors: [.purple, .indigo, .blue]
            ),
            "u/SwingMaster": AvatarStyle(
                emoji: "📈",
                symbol: "arrow.up.right.circle.fill",
                gradientColors: [.green, .mint, .teal]
            ),
            "u/BearGang": AvatarStyle(
                emoji: "🐻",
                symbol: "arrow.down.right.circle.fill",
                gradientColors: [.brown, .orange, .red]
            ),
            "u/DividendDaddy": AvatarStyle(
                emoji: "💰",
                symbol: "dollarsign.circle.fill",
                gradientColors: [.green, .mint, .cyan]
            ),
            "u/NFTCollector": AvatarStyle(
                emoji: "🖼️",
                symbol: "photo.artframe",
                gradientColors: [.pink, .purple, .blue]
            ),
            "u/MacroTrader": AvatarStyle(
                emoji: "🌐",
                symbol: "globe.americas.fill",
                gradientColors: [.blue, .cyan, .teal]
            ),
            "u/PennyStockPro": AvatarStyle(
                emoji: "🪙",
                symbol: "centsign.circle.fill",
                gradientColors: [.orange, .yellow, .green]
            ),
            "u/CryptoMiner": AvatarStyle(
                emoji: "⛏️",
                symbol: "server.rack",
                gradientColors: [.gray, .blue, .cyan]
            ),
            "u/ThetaGang": AvatarStyle(
                emoji: "θ",
                symbol: "infinity.circle.fill",
                gradientColors: [.purple, .pink, .red]
            ),
            "u/GrowthHacker": AvatarStyle(
                emoji: "🚀",
                symbol: "arrow.up.circle.fill",
                gradientColors: [.blue, .purple, .pink]
            ),
            "u/RealEstateBull": AvatarStyle(
                emoji: "🏢",
                symbol: "building.2.fill",
                gradientColors: [.brown, .orange, .yellow]
            ),
            "u/ForexTrader": AvatarStyle(
                emoji: "💱",
                symbol: "eurosign.circle.fill",
                gradientColors: [.blue, .green, .teal]
            ),
            "u/ChipInvestor": AvatarStyle(
                emoji: "🔌",
                symbol: "cpu.fill",
                gradientColors: [.green, .blue, .purple]
            ),
            "u/TechTrader": AvatarStyle(
                emoji: "💻",
                symbol: "laptopcomputer",
                gradientColors: [.blue, .indigo, .purple]
            ),
            "u/AppleFan": AvatarStyle(
                emoji: "🍎",
                symbol: "applelogo",
                gradientColors: [.red, .pink, .purple]
            ),
            "u/ValueSeeker": AvatarStyle(
                emoji: "🔍",
                symbol: "magnifyingglass.circle.fill",
                gradientColors: [.blue, .cyan, .teal]
            ),
            "u/DividendKing": AvatarStyle(
                emoji: "👑",
                symbol: "crown.fill",
                gradientColors: [.yellow, .orange, .red]
            ),
            "u/ElonFollower": AvatarStyle(
                emoji: "🚗",
                symbol: "car.fill",
                gradientColors: [.red, .orange, .yellow]
            ),
            "u/EVInvestor": AvatarStyle(
                emoji: "⚡",
                symbol: "bolt.car.fill",
                gradientColors: [.yellow, .green, .blue]
            ),
            "u/Trader123": AvatarStyle(
                emoji: "💹",
                symbol: "chart.bar.fill",
                gradientColors: [.blue, .purple, .pink]
            ),
            "u/Investor": AvatarStyle(
                emoji: "📊",
                symbol: "chart.pie.fill",
                gradientColors: [.green, .blue, .purple]
            ),
            "u/You": AvatarStyle(
                emoji: "😎",
                symbol: "person.crop.square.filled.and.at.rectangle",
                gradientColors: [.purple, .blue, .cyan]
            )
        ]

        // Return avatar for username, or default if not found
        return avatarMap[username] ?? AvatarStyle(
            emoji: "👤",
            symbol: "person.crop.circle.fill",
            gradientColors: [.purple, .blue, .cyan]
        )
    }
}
