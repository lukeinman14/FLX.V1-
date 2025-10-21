import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var navigateToTicker: String?
    @State private var navigateToProfile: String?

    var initialSearchText: String = ""
    private let userDataManager = UserDataManager.shared

    init(initialSearchText: String = "") {
        self.initialSearchText = initialSearchText
    }

    // Demo users for search results - using UserDataManager for net worth
    private var allUsers: [SearchableUser] {
        [
            SearchableUser(username: "u/You", bio: "Your profile", netWorth: userDataManager.getNetWorth(for: "u/You")),
            SearchableUser(username: "u/CryptoWhale", bio: "Bitcoin maximalist. Been in crypto since 2013.", netWorth: userDataManager.getNetWorth(for: "u/CryptoWhale")),
            SearchableUser(username: "u/ByteWhale", bio: "Trading AI stocks and options. NVDA gang.", netWorth: userDataManager.getNetWorth(for: "u/ByteWhale")),
            SearchableUser(username: "u/QuantJunkie", bio: "Quantitative trader. Risk management is king.", netWorth: userDataManager.getNetWorth(for: "u/QuantJunkie")),
            SearchableUser(username: "u/TechBull", bio: "Long tech. Semiconductors are the future.", netWorth: userDataManager.getNetWorth(for: "u/TechBull")),
            SearchableUser(username: "u/DiamondHands", bio: "HODL since 2017. Never selling.", netWorth: userDataManager.getNetWorth(for: "u/DiamondHands")),
            SearchableUser(username: "u/AnonFin", bio: "Building wealth quietly.", netWorth: userDataManager.getNetWorth(for: "u/AnonFin")),
            SearchableUser(username: "u/WhaleFin", bio: "Whale trader. Market maker.", netWorth: userDataManager.getNetWorth(for: "u/WhaleFin")),
            SearchableUser(username: "u/ChipInvestor", bio: "Semiconductor investor. Long NVDA.", netWorth: userDataManager.getNetWorth(for: "u/ChipInvestor")),
            SearchableUser(username: "u/ValueSeeker", bio: "Warren Buffett disciple. Long-term value only.", netWorth: userDataManager.getNetWorth(for: "u/ValueSeeker")),
            SearchableUser(username: "u/AppleFan", bio: "Apple ecosystem investor. AAPL to the moon.", netWorth: userDataManager.getNetWorth(for: "u/AppleFan")),
            SearchableUser(username: "u/DividendKing", bio: "Living off dividends. FIRE achieved at 35.", netWorth: userDataManager.getNetWorth(for: "u/DividendKing")),
            SearchableUser(username: "u/ElonFollower", bio: "Tesla investor. Following Elon's vision.", netWorth: userDataManager.getNetWorth(for: "u/ElonFollower")),
            SearchableUser(username: "u/TechTrader", bio: "Tech stock trader. High growth or bust.", netWorth: userDataManager.getNetWorth(for: "u/TechTrader")),
            SearchableUser(username: "u/EVInvestor", bio: "Electric vehicle investor. The future is electric.", netWorth: userDataManager.getNetWorth(for: "u/EVInvestor")),
            SearchableUser(username: "u/CryptoSage", bio: "Crypto analyst. On-chain metrics expert.", netWorth: userDataManager.getNetWorth(for: "u/CryptoSage")),
            SearchableUser(username: "u/HashHound", bio: "Crypto miner. Mining since 2015.", netWorth: userDataManager.getNetWorth(for: "u/HashHound")),
            SearchableUser(username: "u/Trader123", bio: "Day trader. Scalping the markets.", netWorth: userDataManager.getNetWorth(for: "u/Trader123")),
            SearchableUser(username: "u/StackSats", bio: "Stacking sats. Bitcoin only.", netWorth: userDataManager.getNetWorth(for: "u/StackSats")),
            SearchableUser(username: "u/ByteNomad", bio: "Digital nomad. Trading from anywhere.", netWorth: userDataManager.getNetWorth(for: "u/ByteNomad")),
            SearchableUser(username: "u/SpiceTrader", bio: "Options trader. High risk, high reward.", netWorth: userDataManager.getNetWorth(for: "u/SpiceTrader")),
            SearchableUser(username: "u/Investor", bio: "Long-term investor. Patience pays.", netWorth: userDataManager.getNetWorth(for: "u/Investor")),
            SearchableUser(username: "u/NewbieFin", bio: "New to investing. Learning every day.", netWorth: userDataManager.getNetWorth(for: "u/NewbieFin")),
            SearchableUser(username: "u/StartupGuy", bio: "Startup investor. High risk, high reward.", netWorth: userDataManager.getNetWorth(for: "u/StartupGuy")),
            SearchableUser(username: "u/LearningToTrade", bio: "Learning to trade. Practice makes perfect.", netWorth: userDataManager.getNetWorth(for: "u/LearningToTrade")),
            SearchableUser(username: "u/JustStarted", bio: "Just started investing. Building wealth.", netWorth: userDataManager.getNetWorth(for: "u/JustStarted"))
        ]
    }

    // Demo posts for search results (expanded)
    private let allPosts = [
        SearchablePost(username: "u/CryptoWhale", text: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto", ticker: "BTC", hashtags: ["Bitcoin", "Crypto"]),
        SearchablePost(username: "u/ByteWhale", text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading", ticker: "NVDA", hashtags: ["AI", "Trading"]),
        SearchablePost(username: "u/QuantJunkie", text: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement", ticker: "NVDA", hashtags: ["TechnicalAnalysis", "RiskManagement"]),
        SearchablePost(username: "u/MoonTrader", text: "$ETH looking strong above 4k. Layer 2 activity is exploding. #Ethereum #DeFi", ticker: "ETH", hashtags: ["Ethereum", "DeFi"]),
        SearchablePost(username: "u/TechBull", text: "AI revolution is here. $NVDA $AMD both crushing it. #Technology #Semiconductors", ticker: "NVDA", hashtags: ["Technology", "Semiconductors"]),
        SearchablePost(username: "u/DiamondHands", text: "Not selling my $BTC. Been holding since 2017. Diamond hands forever. #HODL #Bitcoin", ticker: "BTC", hashtags: ["HODL", "Bitcoin"]),
        SearchablePost(username: "u/ByteNomad", text: "Shoutout to @CryptoWhale for the alpha. Following your BTC strategy!", ticker: "BTC", hashtags: ["Bitcoin"]),
        SearchablePost(username: "u/SpiceTrader", text: "Just saw @ByteWhale's NVDA play. Might follow suit on this one.", ticker: "NVDA", hashtags: ["Trading"]),
        SearchablePost(username: "u/AlgoKing", text: "Backtested my new $SPY strategy. 67% win rate over 5 years. Time to deploy capital. #AlgoTrading #SPY", ticker: "SPY", hashtags: ["AlgoTrading", "SPY"]),
        SearchablePost(username: "u/ValueInvestor", text: "Market cap doesn't matter if the business is solid. $AAPL still undervalued at these levels. #Value #LongTerm", ticker: "AAPL", hashtags: ["Value", "LongTerm"]),
        SearchablePost(username: "u/WSBDegenerate", text: "$TSLA 0DTE calls printing! Up 400% in 2 hours. This is the way. #YOLO #WSB", ticker: "TSLA", hashtags: ["YOLO", "WSB"]),
        SearchablePost(username: "u/DeFiNinja", text: "Staking $ETH at 4.5% APY while lending it out at 12%. DeFi composability is insane. #DeFi #Ethereum", ticker: "ETH", hashtags: ["DeFi", "Ethereum"]),
        SearchablePost(username: "u/SwingMaster", text: "$AMD setting up for a perfect swing. Breaking resistance with volume. Targeting $200. #SwingTrading #TechnicalAnalysis", ticker: "AMD", hashtags: ["SwingTrading", "TechnicalAnalysis"]),
        SearchablePost(username: "u/BearGang", text: "SPY put spreads looking juicy. Market way too extended. Correction incoming. #Bears #SPY", ticker: "SPY", hashtags: ["Bears", "SPY"]),
        SearchablePost(username: "u/DividendDaddy", text: "Just collected $12k in quarterly dividends. Passive income hits different. #Dividends #FIRE", ticker: nil, hashtags: ["Dividends", "FIRE"]),
        SearchablePost(username: "u/MacroTrader", text: "Fed pivot incoming. $BTC and gold are the plays. Dollar weakness ahead. #Macro #Bitcoin", ticker: "BTC", hashtags: ["Macro", "Bitcoin"]),
        SearchablePost(username: "u/CryptoMiner", text: "Mined 2.5 $BTC this month. Electricity costs down 30% with new solar setup. #Mining #Bitcoin", ticker: "BTC", hashtags: ["Mining", "Bitcoin"]),
        SearchablePost(username: "u/ThetaGang", text: "Sold 50 $AAPL covered calls this week. Premium collected: $8,400. Theta gang wins again. #Options #ThetaGang", ticker: "AAPL", hashtags: ["Options", "ThetaGang"]),
        SearchablePost(username: "u/GrowthHacker", text: "$NVDA $AMD $TSLA - the holy trinity of growth. Not selling for 10 years minimum. #Growth #LongTerm", ticker: "NVDA", hashtags: ["Growth", "LongTerm"]),
        SearchablePost(username: "u/RealEstateBull", text: "Closed on another rental property. Cash flow: $2,800/month. Real estate > stocks. #RealEstate #CashFlow", ticker: nil, hashtags: ["RealEstate", "CashFlow"]),
        SearchablePost(username: "u/CryptoWhale", text: "@DiamondHands you still holding? This dip is just noise. $BTC to 200k this cycle. #Bitcoin", ticker: "BTC", hashtags: ["Bitcoin"]),
        SearchablePost(username: "u/QuantJunkie", text: "Sharpe ratio on my portfolio hit 2.1 this quarter. Risk-adjusted returns are what matter. #Quant #Portfolio", ticker: nil, hashtags: ["Quant", "Portfolio"]),
        SearchablePost(username: "u/MoonTrader", text: "Layer 2 volume just flipped Ethereum mainnet. $ETH scalability thesis playing out perfectly. #Ethereum #Layer2", ticker: "ETH", hashtags: ["Ethereum", "Layer2"]),
        SearchablePost(username: "u/ForexTrader", text: "EUR/USD breaking 1.10. Dollar index looking weak. Time to scale into long positions. #Forex #Trading", ticker: nil, hashtags: ["Forex", "Trading"]),
        SearchablePost(username: "u/PennyStockPro", text: "Found a micro-cap gem. $2M market cap, $5M revenue. 10x potential here. DM for ticker. #PennyStocks", ticker: nil, hashtags: ["PennyStocks"])
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.textSecondary)
                    .font(.system(size: 18))

                TextField("Search for $tickers, @users, #hashtags...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(Theme.textPrimary)
                    .font(Theme.bodyFont())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.textSecondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.divider, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Search results
            if searchText.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.textSecondary.opacity(0.5))

                    Text("Search for stocks, users, and posts")
                        .font(Theme.headingFont())
                        .foregroundStyle(Theme.textPrimary)

                    Text("Try $BTC, @CryptoWhale, or #Bitcoin")
                        .font(Theme.bodyFont())
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Show ticker quick action if ticker detected
                        if let ticker = detectTicker(in: searchText) {
                            TickerQuickAction(ticker: ticker, navigateToTicker: $navigateToTicker)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }

                        // Show matching users
                        let userResults = filteredUsers
                        if !userResults.isEmpty {
                            Text("Users")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .padding(.bottom, 8)

                            ForEach(userResults, id: \.username) { user in
                                UserQuickAction(user: user, navigateToProfile: $navigateToProfile)
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 8)
                            }
                        }

                        // Show matching posts
                        let results = filteredPosts
                        if !results.isEmpty {
                            Text("Posts")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, userResults.isEmpty ? 16 : 8)
                                .padding(.bottom, 8)

                            ForEach(results, id: \.username) { post in
                                NavigationLink {
                                    PostDetailView(post: Post(
                                        author: User(handle: post.username, avatar: "person", score: 0),
                                        text: post.text,
                                        upvotes: Int.random(in: 100...10000),
                                        comments: [],
                                        reposts: Int.random(in: 10...1000),
                                        timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400))
                                    ))
                                } label: {
                                    FeedRow(
                                        avatar: AnyView(AvatarHelper.avatarView(for: post.username, size: 44)),
                                        username: post.username.withoutUsernamePrefix,
                                        text: TickerFormat.normalizePrefixes(in: post.text),
                                        upvoteScore: Int.random(in: 100...10000),
                                        comments: "\(Int.random(in: 10...1000))",
                                        reposts: "\(Int.random(in: 10...500))",
                                        timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400)),
                                        onProfileTap: {
                                            navigateToProfile = post.username
                                        }
                                    )
                                }
                            }
                        }

                        // Show no results only if both users and posts are empty
                        if userResults.isEmpty && results.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundStyle(Theme.textSecondary.opacity(0.5))

                                Text("No results found")
                                    .font(Theme.headingFont())
                                    .foregroundStyle(Theme.textPrimary)

                                Text("Try different keywords, users, or tickers")
                                    .font(Theme.bodyFont())
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        }
                    }
                }
            }
        }
        .background(Theme.bg)
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .navigationDestination(item: $navigateToTicker) { ticker in
            TickerDetailView(symbol: ticker)
        }
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username, accent: Theme.accentMuted)
        }
        .onAppear {
            if !initialSearchText.isEmpty {
                searchText = initialSearchText
            }
        }
        #if os(iOS)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
    }

    // MARK: - Search Logic

    private func performSearch() {
        // Priority: ticker > username
        if let ticker = detectTicker(in: searchText) {
            navigateToTicker = ticker
        } else if let username = detectUsername(in: searchText) {
            navigateToProfile = username
        }
    }

    private func detectTicker(in text: String) -> String? {
        // Match $TICKER pattern (1-5 uppercase letters after $)
        let pattern = "\\$([A-Z]{1,5})\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        if let match = matches.first {
            let tickerRange = match.range(at: 1) // Capture group 1 (ticker without $)
            return nsString.substring(with: tickerRange)
        }

        return nil
    }

    private func detectHashtags(in text: String) -> [String] {
        // Match #hashtag pattern
        let pattern = "#([A-Za-z0-9_]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        return matches.map { match in
            let hashtagRange = match.range(at: 1) // Capture group 1 (hashtag without #)
            return nsString.substring(with: hashtagRange)
        }
    }

    private func detectUsername(in text: String) -> String? {
        // Match @username or u/username pattern
        let pattern = "[@]([A-Za-z0-9_]+)|u/([A-Za-z0-9_]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }

        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))

        if let match = matches.first {
            // Check which capture group matched
            if match.range(at: 1).location != NSNotFound {
                // @username format
                let usernameRange = match.range(at: 1)
                return "u/" + nsString.substring(with: usernameRange)
            } else if match.range(at: 2).location != NSNotFound {
                // u/username format
                let usernameRange = match.range(at: 2)
                return "u/" + nsString.substring(with: usernameRange)
            }
        }

        return nil
    }

    private var filteredUsers: [SearchableUser] {
        let query = searchText.lowercased()

        // Detect username in search query
        let searchUsername = detectUsername(in: searchText)

        return allUsers.filter { user in
            // Match by @username or u/username
            if let searchUsername = searchUsername, user.username.lowercased() == searchUsername.lowercased() {
                return true
            }

            // Match by partial username (without prefix)
            let usernameWithoutPrefix = user.username.replacingOccurrences(of: "u/", with: "").lowercased()
            if usernameWithoutPrefix.contains(query) || user.username.lowercased().contains(query) {
                return true
            }

            // Match by bio
            if user.bio.lowercased().contains(query) {
                return true
            }

            return false
        }
    }

    private var filteredPosts: [SearchablePost] {
        let query = searchText.lowercased()

        // Detect ticker, hashtags, and username in search query
        let searchTicker = detectTicker(in: searchText)
        let searchHashtags = detectHashtags(in: searchText)
        let searchUsername = detectUsername(in: searchText)

        return allPosts.filter { post in
            // Match by ticker
            if let searchTicker = searchTicker, post.ticker?.uppercased() == searchTicker.uppercased() {
                return true
            }

            // Match by hashtag
            if !searchHashtags.isEmpty {
                let postHashtagsLower = post.hashtags.map { $0.lowercased() }
                if searchHashtags.contains(where: { searchHashtag in
                    postHashtagsLower.contains(searchHashtag.lowercased())
                }) {
                    return true
                }
            }

            // Match by username mention (@username in post text or author)
            if let searchUsername = searchUsername {
                // Check if post author matches
                if post.username.lowercased() == searchUsername.lowercased() {
                    return true
                }
                // Check if post text mentions the user
                let usernameWithoutPrefix = searchUsername.replacingOccurrences(of: "u/", with: "")
                if post.text.lowercased().contains("@\(usernameWithoutPrefix.lowercased())") {
                    return true
                }
            }

            // Match by keyword in text or username
            if post.text.lowercased().contains(query) || post.username.lowercased().contains(query) {
                return true
            }

            return false
        }
    }
}

// MARK: - Ticker Quick Action Card
struct TickerQuickAction: View {
    let ticker: String
    @Binding var navigateToTicker: String?
    @ObservedObject private var api = StockAPIService.shared

    var body: some View {
        Button(action: { navigateToTicker = ticker }) {
            HStack(spacing: 12) {
                // Ticker icon
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 24))
                    .foregroundStyle(Theme.accentMuted)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("$\(ticker)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)

                        // Live/Mock indicator
                        if let isLive = api.isLiveData[ticker] {
                            HStack(spacing: 2) {
                                Circle()
                                    .fill(isLive ? Color.green : Color.red)
                                    .frame(width: 4, height: 4)
                                Text(isLive ? "LIVE" : "MOCK")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(isLive ? .green : .red)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill((isLive ? Color.green : Color.red).opacity(0.15))
                            )
                        }
                    }

                    Text("Tap to view chart and related posts")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                // Price info if available
                if let stockData = api.stockCache[ticker] {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("$\(stockData.price, specifier: "%.2f")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)

                        Text("\(stockData.change >= 0 ? "+" : "")\(stockData.changePercent, specifier: "%.1f")%")
                            .font(.system(size: 12))
                            .foregroundStyle(stockData.change >= 0 ? .green : .red)
                    }
                } else {
                    ProgressView()
                        .tint(Theme.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.accentMuted.opacity(0.3), lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            // Pre-fetch ticker data
            Task.detached {
                await StockAPIService.shared.fetchStockData(symbol: ticker)
            }
        }
    }
}

// MARK: - User Quick Action Card
struct UserQuickAction: View {
    let user: SearchableUser
    @Binding var navigateToProfile: String?
    private let userDataManager = UserDataManager.shared

    var body: some View {
        Button(action: { navigateToProfile = user.username }) {
            HStack(spacing: 12) {
                // User avatar - clickable with unique avatar
                Button(action: { navigateToProfile = user.username }) {
                    AvatarHelper.avatarView(for: user.username, size: 40)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.username.withoutUsernamePrefix)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(user.bio)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Net worth - using UserDataManager for consistent formatting
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Net Worth")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textSecondary)

                    Text(userDataManager.formatNetWorth(user.netWorth))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.accentMuted)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.divider, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Models
struct SearchableUser {
    let username: String
    let bio: String
    let netWorth: Double
}

struct SearchablePost {
    let username: String
    let text: String
    let ticker: String?
    let hashtags: [String]
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .preferredColorScheme(.dark)
}
