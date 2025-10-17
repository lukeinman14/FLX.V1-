import SwiftUI

struct BankAccount { var balance: String }

struct ProfileView: View {
    var username: String
    var accent: Color = Theme.accentMuted
    @Environment(\.dismiss) private var dismiss

    // User data manager
    private let userDataManager = UserDataManager.shared
    private let model = GamificationModel.demo

    // Get user profile data
    private var userProfile: UserProfile {
        userDataManager.getUserProfile(for: username)
    }

    private let viewerNetWorthUSD: Double = 82_000 // u/You's net worth
    private var viewedNetWorthUSD: Double { userProfile.netWorthUSD }
    private var canRequestAdvice: Bool { viewedNetWorthUSD > viewerNetWorthUSD }

    @State private var selectedTab: ProfileTab = .thoughts
    @State private var followersCount: Int = 892
    @State private var followingCount: Int = 234
    @State private var showStats = false
    @State private var showShareSheet = false
    @State private var selectedPost: ProfileMockPost?
    @State private var selectedRepost: RepostedPost?
    @State private var navigateToProfile: String?
    @State private var navigateToPostDetail: ProfileMockPost?
    @StateObject private var repostManager = RepostManager.shared

    // Stats data
    @State private var timeframe: Timeframe = .weekly
    enum Timeframe: String, CaseIterable { case daily = "Daily", weekly = "Weekly", monthly = "Monthly", yearly = "Yearly" }

    private let gain: [Timeframe: String] = [.daily: "+0.6%", .weekly: "+2.3%", .monthly: "+6.1%", .yearly: "+24%"]
    private let holdings: [Holding] = [
        Holding(symbol: "AAPL", amount: "1,250 sh", value: "$237k"),
        Holding(symbol: "NVDA", amount: "300 sh", value: "$370k"),
        Holding(symbol: "BTC", amount: "2.1", value: "$138k"),
        Holding(symbol: "ETH", amount: "25", value: "$78k")
    ]
    private let bank = BankAccount(balance: "$125,000")
    private let totalXPWagered: Int = 12850
    private let totalXPWon: Int = 7420

    enum ProfileTab: String, CaseIterable {
        case thoughts = "Thoughts"
        case replies = "Replies"
        case media = "Media"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                spaceBannerSection
                profileInfoSection
                statsButton
                tabNavigation
                contentSection
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        #if os(iOS)
        .ignoresSafeArea(edges: .top)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
        .sheet(isPresented: $showShareSheet) {
            if let post = selectedPost {
                ShareSheet(
                    postURL: "https://flex.app/profile/\(username)/\(UUID().uuidString)",
                    postText: post.text
                )
            }
        }
        .navigationDestination(item: $navigateToProfile) { profileUsername in
            ProfileView(username: profileUsername)
        }
        .navigationDestination(item: $navigateToPostDetail) { post in
            PostDetailView(post: Post(
                author: User(handle: username, avatar: "person", score: 0),
                text: post.text,
                upvotes: post.likes,
                comments: [],
                reposts: post.reposts,
                timestamp: post.timestamp
            ))
        }
    }

    private var spaceBannerSection: some View {
        ZStack(alignment: .topTrailing) {
            // Space/nebula banner background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.2),
                    Color(red: 0.1, green: 0.05, blue: 0.3),
                    Color(red: 0.2, green: 0.1, blue: 0.4),
                    Color(red: 0.15, green: 0.05, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            .overlay(
                // Add some "stars"
                Canvas { context, size in
                    for _ in 0..<50 {
                        let x = Double.random(in: 0...size.width)
                        let y = Double.random(in: 0...size.height)
                        let radius = Double.random(in: 0.5...2.0)

                        context.fill(
                            Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                            with: .color(.white.opacity(Double.random(in: 0.3...1.0)))
                        )
                    }
                }
            )

            // Back button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 44)
                Spacer()
            }
        }
        .clipped()
    }

    private var profileInfoSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                // Large circular profile picture with user's unique CryptoPunk avatar
                AvatarHelper.avatarView(for: username, size: 120)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 4)
                    )
                    .offset(y: -60)

                VStack(spacing: 12) {
                    // Username with verification checkmark
                    HStack(spacing: 8) {
                        Text(username.withoutUsernamePrefix)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)

                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }

                    // Bio text
                    Text(getBio(for: username))
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    // Financial data row
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Net Worth")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                            Text(userDataManager.formatNetWorth(userProfile.netWorthUSD))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Rectangle()
                            .fill(Theme.divider)
                            .frame(width: 1, height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tier")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                            Text(model.currentTier(for: userProfile)?.name.uppercased() ?? "UNRANKED")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Follower stats
                    HStack(spacing: 24) {
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("\(followersCount.formatted())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Followers")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }

                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Text("\(followingCount.formatted())")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Theme.textPrimary)
                                Text("Following")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                        }
                    }
                }
                .offset(y: -40)
            }
        }
        .padding(.horizontal, 16)
        .background(Theme.bg)
    }

    private var statsButton: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring()) {
                    showStats.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(accent)

                    Text("\(username.withoutUsernamePrefix)'s Stats")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Spacer()

                    Image(systemName: showStats ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
                .background(Theme.surface)
                .overlay(
                    Rectangle()
                        .fill(Theme.divider)
                        .frame(height: 1),
                    alignment: .bottom
                )
            }

            if showStats {
                VStack(spacing: 16) {
                    metrics
                    accounts
                    xpWagerStats
                    adviceCard
                    holdingsList
                }
                .padding(.top, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
    }

    private var tabNavigation: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(selectedTab == tab ? Theme.textPrimary : Theme.textSecondary)

                        Rectangle()
                            .fill(selectedTab == tab ? Theme.accent : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .background(Theme.bg)
        .overlay(
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var contentSection: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .thoughts:
                thoughtsContent
            case .replies:
                repliesContent
            case .media:
                mediaContent
            }
        }
    }

    // MARK: - Stats Sections (Collapsible)

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Portfolio Gain").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                Spacer()
                timeframePicker
            }
            HStack {
                Text(gain[timeframe] ?? "+0.0%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
                .frame(height: 12)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [accent.opacity(0.7), accent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 160)
                }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surfaceElevated))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
    }

    private var timeframePicker: some View {
        Menu(timeframe.rawValue) {
            ForEach(Timeframe.allCases, id: \.self) { tf in
                Button(tf.rawValue) { timeframe = tf }
            }
        }
        .font(Theme.smallFont())
        .foregroundStyle(Theme.accentMuted)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
    }

    private var accounts: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bank Balance").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text(bank.balance).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text("Tier").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text(model.currentTier(for: userProfile)?.name.uppercased() ?? "UNRANKED").font(Theme.headingFont()).foregroundStyle(accent)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        }
    }

    private var xpWagerStats: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Total XP Wagered").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text("\(totalXPWagered.formatted()) XP").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text("Total XP Won").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text("\(totalXPWon.formatted()) XP").font(Theme.headingFont()).foregroundStyle(Theme.accentMuted)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        }
    }

    private var adviceCard: some View {
        Group {
            if canRequestAdvice {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill").foregroundStyle(accent)
                        Text("Pay for Advice")
                            .font(Theme.headingFont())
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                    }
                    Text("This user has a higher net worth than you. Ask for a tailored plan to improve your net worth.")
                        .font(Theme.smallFont())
                        .foregroundStyle(Theme.textSecondary)
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Choose a tip amount").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                            HStack {
                                adviceChip("100 XP")
                                adviceChip("250 XP")
                                adviceChip("500 XP")
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Or pay with cash").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                            HStack {
                                adviceChip("$10")
                                adviceChip("$25")
                                adviceChip("$50")
                            }
                        }
                        Spacer()
                    }
                    Button {
                        // TODO: trigger advice request flow
                    } label: {
                        Text("Request Advice")
                            .font(Theme.headingFont())
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1)))
                    }
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surfaceElevated))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
            }
        }
    }

    private func adviceChip(_ title: String) -> some View {
        Text(title)
            .font(Theme.smallFont())
            .foregroundStyle(Theme.accentMuted)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Theme.divider, lineWidth: 1))
    }

    private var holdingsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Holdings").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
            ForEach(holdings) { h in
                NavigationLink { StockChatView(symbol: h.symbol) } label: {
                    HStack {
                        Text(h.symbol).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text(h.amount).font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                        Text(h.value).font(Theme.bodyFont()).foregroundStyle(accent)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Theme.surface)
                    .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
                }
            }
        }
        .background(Theme.bg)
    }

    // MARK: - Tab Content

    // Combined timeline of original posts and reposts, sorted chronologically
    private var combinedTimeline: [ProfilePost] {
        var timeline: [ProfilePost] = []

        // Add original posts
        for post in mockPosts {
            timeline.append(.original(post))
        }

        // Add reposts - only those reposted BY this specific user
        for repost in repostManager.repostedPosts where repost.repostedBy == username {
            timeline.append(.repost(repost))
        }

        // Sort by display timestamp (most recent first)
        timeline.sort { $0.displayTimestamp > $1.displayTimestamp }

        return timeline
    }

    private var thoughtsContent: some View {
        VStack(spacing: 0) {
            ForEach(combinedTimeline) { item in
                postRow(for: item)
            }
        }
    }

    @ViewBuilder
    private func postRow(for item: ProfilePost) -> some View {
        switch item {
        case .original(let originalPost):
            postContent(
                post: originalPost,
                isRepost: false,
                originalAuthor: nil,
                displayTimestamp: item.displayTimestamp
            )
        case .repost(let repostedPost):
            postContent(
                post: ProfileMockPost(
                    text: repostedPost.text,
                    likes: repostedPost.likes,
                    reposts: repostedPost.reposts,
                    comments: repostedPost.comments,
                    timestamp: repostedPost.timestamp
                ),
                isRepost: true,
                originalAuthor: repostedPost.originalAuthor,
                displayTimestamp: item.displayTimestamp
            )
        }
    }

    @ViewBuilder
    private func postContent(post: ProfileMockPost, isRepost: Bool, originalAuthor: String?, displayTimestamp: Date) -> some View {
        Button(action: {
            navigateToPostDetail = post
        }) {
            VStack(alignment: .leading, spacing: 12) {
                        // Repost indicator
                        if isRepost {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.2.squarepath")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.textSecondary)
                                Text("\(username.withoutUsernamePrefix) reposted")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.bottom, 4)
                        }

                        // Post header with author info and timestamp
                        HStack(alignment: .top, spacing: 12) {
                            if isRepost, let author = originalAuthor {
                                // Original author's profile picture (clickable)
                                Button(action: {
                                    navigateToProfile = author
                                }) {
                                    AvatarHelper.avatarView(for: author, size: 40)
                                        .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(author.withoutUsernamePrefix)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                }

                                Spacer()

                                Text(displayTimestamp.timeAgo())
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
                            } else {
                                // For original posts, show profile owner's username with profile picture
                                AvatarHelper.avatarView(for: username, size: 40)
                                    .overlay(Circle().stroke(Theme.divider, lineWidth: 1))

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(username.withoutUsernamePrefix)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Theme.textPrimary)
                                }

                                Spacer()

                                Text(displayTimestamp.timeAgo())
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
                            }
                        }

                    // Rich text with highlighting for tickers and hashtags
                    RichPostTextView(text: post.text)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Chart preview if post contains stock ticker
                    if let firstTicker = PostTextParser.extractStockTickers(from: post.text).first {
                        CompactChartPreview(symbol: firstTicker)
                            .padding(.top, 8)
                    }

                    // Engagement buttons
                    HStack(spacing: 20) {
                        // Vote buttons
                        VoteButton(score: post.likes)

                        // Comment
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 16, weight: .medium))
                                Text("\(post.comments)")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(Theme.textSecondary)
                        }
                        .buttonStyle(.plain)

                        // Repost
                        RepostButton(
                            initialCount: "\(post.reposts)",
                            postText: post.text,
                            postAuthor: isRepost ? (originalAuthor ?? username) : username,
                            postLikes: post.likes,
                            postComments: post.comments,
                            postTimestamp: post.timestamp
                        )

                        Spacer()

                        // Share
                        Button(action: {
                            selectedPost = post
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
        .buttonStyle(.plain)
        .padding(16)
        .background(Theme.bg)
        .overlay(
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var repliesContent: some View {
        VStack(spacing: 16) {
            Text("No replies yet")
                .font(.system(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 40)
            Spacer(minLength: 200)
        }
    }

    private var mediaContent: some View {
        VStack(spacing: 16) {
            Text("No media yet")
                .font(.system(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 40)
            Spacer(minLength: 200)
        }
    }

    private var likesContent: some View {
        VStack(spacing: 16) {
            Text("No liked posts yet")
                .font(.system(size: 16))
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 40)
            Spacer(minLength: 200)
        }
    }

    // MARK: - Helper Functions

    private func getBio(for username: String) -> String {
        let bios: [String: String] = [
            "u/CryptoWhale": "Bitcoin maximalist. Been in crypto since 2013.",
            "u/ByteWhale": "Trading AI stocks and options. NVDA gang.",
            "u/QuantJunkie": "Quantitative trader. Risk management is king.",
            "u/MoonTrader": "ETH bull. DeFi enthusiast.",
            "u/TechBull": "Long tech. Semiconductors are the future.",
            "u/DiamondHands": "HODL since 2017. Never selling.",
            "u/AnonFin": "Building wealth quietly.",
            "u/ByteNomad": "Digital nomad. Trading from anywhere.",
            "u/SpiceTrader": "Options trader. High risk, high reward."
        ]
        return bios[username] ?? "Investor and trader."
    }

    private var mockPosts: [ProfileMockPost] {
        [
            ProfileMockPost(text: "Just hit my $AAPL target. Taking profits and waiting for the next dip. Patience pays off in this market. #Apple #ProfitTaking", likes: 1876, reposts: 234, comments: 127, timestamp: Date().addingTimeInterval(-1800)),
            ProfileMockPost(text: "$NVDA momentum is insane right now. Heavy volume and IV spike could setup for gamma squeeze. #AI #Trading", likes: 5300, reposts: 412, comments: 298, timestamp: Date().addingTimeInterval(-3600)),
            ProfileMockPost(text: "Stacking weekly DCA on dips. #Bitcoin #DCA", likes: 1200, reposts: 87, comments: 214, timestamp: Date().addingTimeInterval(-7200)),
            ProfileMockPost(text: "$TSLA breaking out of consolidation. Could see 300 if momentum holds. #Tesla #ElonMusk #EV", likes: 945, reposts: 187, comments: 156, timestamp: Date().addingTimeInterval(-10800)),
            ProfileMockPost(text: "Rebalancing 70/30 portfolio. Risk management is everything. #Investing #PortfolioManagement", likes: 692, reposts: 31, comments: 89, timestamp: Date().addingTimeInterval(-14400))
        ]
    }
}

struct ProfileMockPost: Hashable {
    let text: String
    let likes: Int
    let reposts: Int
    let comments: Int
    let timestamp: Date

    init(text: String, likes: Int, reposts: Int, comments: Int, timestamp: Date = Date()) {
        self.text = text
        self.likes = likes
        self.reposts = reposts
        self.comments = comments
        self.timestamp = timestamp
    }
}

#Preview {
    NavigationStack { ProfileView(username: "u/AnonFin") }
        .preferredColorScheme(.dark)
}
