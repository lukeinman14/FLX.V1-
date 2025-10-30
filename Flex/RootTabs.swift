import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct HomeWithDrawer: View {
    @Environment(PlayerState.self) private var player
    @State private var isDrawerOpen = false
    @State private var path = NavigationPath()
    @State private var showSearch = false

    enum HomeDestination: Hashable { case profile, explore, notifications, settings, bookmarks, lists, search }

    var body: some View {
        NavigationStack(path: $path) {
            HomeDrawer(isOpen: $isDrawerOpen, items: drawerItems) {
                FeedDemo()
            }
            .navigationDestination(for: HomeDestination.self) { dest in
                Group {
                    switch dest {
                    case .profile: MyProfileView()
                    case .explore: ExploreView()
                    case .notifications: AppNotificationsScreen()
                    case .settings: AppSettingsView()
                    case .bookmarks: BookmarksView()
                    case .lists: ListsView()
                    case .search: SearchView()
                    }
                }
                .environment(player)
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .overlay(alignment: .top) {
                // Full-screen gradient blur from top of screen down
                if !isDrawerOpen {
                    VStack(spacing: 0) {
                        // Graduated blur layers - stronger at top, weaker at bottom
                        ZStack {
                            // Layer 1: Strong blur at top (most intense)
                            LinearGradient(
                                colors: [
                                    Theme.bg,
                                    Theme.bg,
                                    Theme.bg,
                                    Theme.bg.opacity(0.98),
                                    Theme.bg.opacity(0.85),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blur(radius: 60)
                            .frame(height: 100)
                            .offset(y: 0)

                            // Layer 2: Medium blur in middle
                            LinearGradient(
                                colors: [
                                    Theme.bg.opacity(0.92),
                                    Theme.bg.opacity(0.80),
                                    Theme.bg.opacity(0.65),
                                    Theme.bg.opacity(0.45),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blur(radius: 30)
                            .frame(height: 140)
                            .offset(y: 20)

                            // Layer 3: Light blur near bottom
                            LinearGradient(
                                colors: [
                                    Theme.bg.opacity(0.50),
                                    Theme.bg.opacity(0.35),
                                    Theme.bg.opacity(0.20),
                                    Theme.bg.opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blur(radius: 12)
                            .frame(height: 180)
                            .offset(y: 0)
                        }
                        .frame(height: 180)

                        Spacer()
                    }
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if !isDrawerOpen {
                    HStack(spacing: 16) {
                        // Profile photo button - liquid glass floating
                        Button(action: { withAnimation(.spring()) { isDrawerOpen = true } }) {
                            AvatarHelper.avatarView(for: "u/You", size: 36)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.4),
                                                    Color.white.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial.opacity(0.3))
                                )
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.leading, 16)

                        Spacer()

                        // Title in center
                        Text("Home Feed")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

                        Spacer()

                        // Search button - liquid glass with distortion effect like tab bar
                        Button(action: { path.append(HomeDestination.search) }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    ZStack {
                                        // Base blur/material for distortion effect
                                        Circle()
                                            .fill(.ultraThinMaterial)

                                        // Subtle tint overlay
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.12),
                                                        Color.white.opacity(0.06)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )

                                        // Glass border
                                        Circle()
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        Color.white.opacity(0.35),
                                                        Color.white.opacity(0.08)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    }
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
                        }
                        .padding(.trailing, 16)
                    }
                    .frame(height: 52)
                }
            }
        }
        #if os(iOS)
        .toolbarVisibility(isDrawerOpen ? .hidden : .visible, for: .tabBar)
        #endif
    }

    private var drawerItems: [DrawerItem] {
        [
            DrawerItem(title: "My Profile", systemImage: "person.crop.circle") { open(.profile) },
            DrawerItem(title: "Notifications", systemImage: "bell") { open(.notifications) },
            DrawerItem(title: "Bookmarks", systemImage: "bookmark") { open(.bookmarks) },
            DrawerItem(title: "Lists", systemImage: "list.bullet") { open(.lists) },
            DrawerItem(title: "Settings", systemImage: "gearshape") { open(.settings) }
        ]
    }

    private func open(_ dest: HomeDestination) {
        withAnimation(.spring()) { isDrawerOpen = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            path.append(dest)
        }
    }
}

struct RootTabs: View {
    @State private var player = PlayerState(profile: UserProfile(username: "u/You", netWorthUSD: 82_000))
    @State private var selectedTab: Int = 0
    private let model = GamificationModel.demo

    var body: some View {
        ZStack {
        TabView(selection: $selectedTab) {
            HomeWithDrawer()
                .tabItem { Image(systemName: "house") }
                .environment(player)
                .tag(0)

            NavigationStack {
                if canChat { MessagesDemo() } else { ChatLockedView(requiredTier: player.minTierForChat) }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            .toolbarVisibility(.visible, for: .tabBar)
            #endif
            .tabItem { Image(systemName: "envelope") }
            .environment(player)
            .tag(1)

            NavigationStack { NotificationsView() }
                #if os(iOS)
                .navigationBarHidden(true)
                .toolbarVisibility(.visible, for: .tabBar)
                #endif
                .tabItem { Image(systemName: "bell") }
                .environment(player)
                .tag(2)

            NavigationStack { ArenaListView() }
                #if os(iOS)
                .navigationBarHidden(true)
                .toolbarVisibility(.visible, for: .tabBar)
                #endif
                .tabItem { Image(systemName: "chart.line.uptrend.xyaxis") }
                .environment(player)
                .tag(3)

            NavigationStack { LeaderboardView() }
                #if os(iOS)
                .navigationBarHidden(true)
                .toolbarVisibility(.visible, for: .tabBar)
                #endif
                .tabItem { Image(systemName: "trophy") }
                .environment(player)
                .tag(4)
        }
        .tint(AppSettings.shared.isDarkMode
            ? Theme.accentMuted
            : Color(red: 0.18, green: 0.50, blue: 0.22))  // Light mode: darker forest green to match plus button
        .onAppear { configureTabBar() }
        .background(Theme.bg.ignoresSafeArea())
        .environment(player)
        .environment(\.tabSelection, $selectedTab)
        .owlRefreshEnabled()
        .persistentSystemOverlays(.visible)
        }
    }

    private var canChat: Bool {
        // gate chat if below required tier
        guard let requiredIndex = model.tiers.firstIndex(where: { $0.name == player.minTierForChat }),
              let currentIndex = model.tiers.firstIndex(where: { $0.contains(player.profile.netWorthUSD) }) else { return true }
        return currentIndex >= requiredIndex
    }

    private func configureTabBar() {
        #if os(iOS)
        // Configure native tab bar with liquid glass effect
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()

        // Use system material for blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)

        appearance.backgroundEffect = blurEffect
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
}

// Mock feed post model
private struct FeedPost: Identifiable {
    let id = UUID()
    let username: String
    let avatar: String
    let text: String
    let upvotes: Int
    let comments: String
    let reposts: String
    let timestamp: Date
}

private struct FeedDemo: View {
    @State private var navigateToProfile: String?
    @State private var showPostTypeDrawer = false
    @State private var posts: [FeedPost] = []
    @Environment(\.tabSelection) private var tabSelection

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(posts) { post in
                        NavigationLink {
                            postDetailView(for: post)
                        } label: {
                            FeedRow(
                                avatar: AnyView(AvatarHelper.avatarView(for: post.username, size: 44)),
                                username: post.username,
                                text: TickerFormat.normalizePrefixes(in: post.text),
                                upvoteScore: post.upvotes,
                                comments: post.comments,
                                reposts: post.reposts,
                                timestamp: post.timestamp,
                                onProfileTap: {
                                    navigateToProfile = post.username
                                }
                            )
                        }
                    }
                }
            }
            .refreshable {
                await refreshFeed()
            }
            .background(Theme.bg)
            .onAppear {
                if posts.isEmpty {
                    posts = generateInitialPosts()
                }
            }

            // Blur overlay - blurs everything except plus button (below it in z-order)
            if showPostTypeDrawer {
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showPostTypeDrawer = false
                        }
                    }
                    .transition(.opacity)
            }

            // Floating Plus Button - placed ABOVE blur layer so it stays sharp
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showPostTypeDrawer = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: AppSettings.shared.isDarkMode
                                            ? [Theme.accentMuted, Theme.accent]  // Dark mode: teal gradient
                                            : [Color(red: 0.18, green: 0.50, blue: 0.22), Color(red: 0.22, green: 0.55, blue: 0.26)],  // Light mode: forest green gradient
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 45, height: 45)
                                .shadow(
                                    color: AppSettings.shared.isDarkMode
                                        ? Theme.accentMuted.opacity(0.4)
                                        : Color(red: 0.18, green: 0.50, blue: 0.22).opacity(0.4),
                                    radius: 12,
                                    x: 0,
                                    y: 4
                                )

                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20) // Much closer to tab bar
                }
            }

            // Post Type Drawer - without blur background
            PostTypeDrawer(isPresented: $showPostTypeDrawer) { postType in
                handlePostTypeSelection(postType)
            }
        }
        .navigationTitle("Home Feed")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
    }

    private func postDetailView(for post: FeedPost) -> some View {
        let repostCount = Int(post.reposts.replacingOccurrences(of: "k", with: "00").replacingOccurrences(of: ".", with: "")) ?? 0
        return PostDetailView(post: Post(
            author: User(handle: post.username, avatar: post.avatar, score: 0),
            text: post.text,
            upvotes: post.upvotes,
            comments: [],
            reposts: repostCount,
            timestamp: post.timestamp
        ))
    }

    private func handlePostTypeSelection(_ postType: PostType) {
        switch postType {
        case .thought:
            print("Create Thought post")
            // TODO: Navigate to thought composer
        case .poll:
            print("Create Poll")
            // TODO: Navigate to poll composer
        case .debate:
            print("Start Debate (Spaces)")
            // TODO: Navigate to debate/spaces creator
        }
    }

    // Generate initial feed posts
    private func generateInitialPosts() -> [FeedPost] {
        let mockPosts: [(username: String, avatar: String, text: String, upvotes: Int, comments: String, reposts: String, minutesAgo: Double)] = [
            ("u/CryptoWhale", "person", "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto", 8742, "1.2k", "543", 30),
            ("u/ByteWhale", "person", "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading", 5300, "412", "87", 180),
            ("u/QuantJunkie", "person.circle.fill", "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement", 856, "89", "43", 120),
            ("u/ByteNomad", "person.circle", "I can't tell if I'm working for money or if money's working me.", 530, "1.2k", "642", 60),
            ("u/StockSensei", "person", "$TSLA earnings next week. Expecting a beat on delivery numbers. Loading up on calls. #Tesla #EV", 2341, "234", "156", 240),
            ("u/DeFiDegen", "person.circle.fill", "Just aped into a new DeFi protocol. 5000% APY can't go wrong, right? Right?? #DeFi #YOLO", 1823, "567", "234", 90),
            ("u/WallStreetBets", "person", "$SPY puts printing today. The market is finally correcting. Bear gang rise up! #Stocks #Options", 4521, "891", "445", 45),
            ("u/CryptoMom", "person.circle", "Finally convinced my boomer parents to buy $BTC. We're all going to make it! #Bitcoin #WAGMI", 967, "123", "78", 150),
            ("u/TechBro99", "person", "$AAPL releasing new AI features next quarter. This is going to be huge for the stock. #Apple #AI", 3456, "445", "289", 300),
            ("u/DiamondHands", "person.circle.fill", "Been holding $GME for 3 years now. Down 80% but still not selling. Diamond hands forever! #GME #HODL", 6789, "2.1k", "1.3k", 15),
            ("u/ValueInvestor", "person", "Everyone's chasing memes while I'm building a dividend portfolio. Slow and steady wins the race. #Investing #Dividends", 423, "67", "34", 420),
            ("u/CryptoKing", "person.circle", "$ETH finally broke resistance! Next stop $5k. The flippening is coming! #Ethereum #Crypto", 5432, "678", "456", 75),
            ("u/OptionsTrader", "person", "Made 300% on $NVDA calls this week. Sometimes the play just works perfectly. #Options #Trading", 2876, "334", "212", 105),
            ("u/BeginnerInvestor", "person.circle.fill", "Just opened my first brokerage account. Any tips for a complete beginner? #Investing #NewTrader", 789, "456", "123", 180),
            ("u/MacroAnalyst", "person", "Fed's next move is crucial. Expecting rates to hold steady but market seems pricing in cuts. #Economics #Fed", 1234, "234", "145", 270),
            ("u/AltcoinHunter", "person.circle", "Found a gem at 10M market cap. Not sharing the ticker yet. IYKYK #Crypto #Altcoins", 3421, "891", "567", 45),
            ("u/DayTrader", "person", "Up $15k today scalping $SPY options. This is the best trading day I've had all month! #DayTrading #Options", 2109, "289", "178", 30),
            ("u/LongTermHODL", "person.circle.fill", "Stop checking prices every 5 minutes. Zoom out. We're still early in this cycle. #Patience #Investing", 4567, "567", "389", 360),
            ("u/TrendFollower", "person", "$COIN showing massive strength. Breaking out of consolidation. Time to take a position. #Crypto #TA", 1678, "223", "134", 90),
            ("u/RiskManager", "person.circle", "Remember: proper position sizing and stop losses. Protect your capital first, make gains second. #RiskManagement #Trading", 987, "145", "89", 210)
        ]

        return mockPosts.map { post in
            FeedPost(
                username: post.username,
                avatar: post.avatar,
                text: post.text,
                upvotes: post.upvotes,
                comments: post.comments,
                reposts: post.reposts,
                timestamp: Date().addingTimeInterval(-post.minutesAgo * 60)
            )
        }
    }

    // Refresh feed with new posts
    private func refreshFeed() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let newPosts = generateNewPosts()
        await MainActor.run {
            // Add new posts to the top
            posts.insert(contentsOf: newPosts, at: 0)
        }
    }

    // Generate new posts for refresh
    private func generateNewPosts() -> [FeedPost] {
        let freshPosts: [(username: String, avatar: String, text: String, upvotes: Int, comments: String, reposts: String, secondsAgo: Double)] = [
            ("u/MarketWatch", "person", "BREAKING: $SPY hits new all-time high. Bull market continues! #Stocks #Markets", Int.random(in: 1000...5000), "\(Int.random(in: 50...200))", "\(Int.random(in: 20...100))", Double.random(in: 5...30)),
            ("u/CryptoNews", "person.circle", "$BTC pumping! Looks like whales are accumulating again. #Bitcoin", Int.random(in: 2000...8000), "\(Int.random(in: 100...500))", "\(Int.random(in: 50...300))", Double.random(in: 10...45)),
            ("u/TechAnalysis", "person.circle.fill", "$NVDA earnings preview: analysts expecting strong quarter driven by AI demand. #NVIDIA", Int.random(in: 500...3000), "\(Int.random(in: 30...150))", "\(Int.random(in: 20...80))", Double.random(in: 15...60))
        ]

        return freshPosts.map { post in
            FeedPost(
                username: post.username,
                avatar: post.avatar,
                text: post.text,
                upvotes: post.upvotes,
                comments: post.comments,
                reposts: post.reposts,
                timestamp: Date().addingTimeInterval(-post.secondsAgo)
            )
        }
    }

}

private struct MessagesDemo: View {
    @State private var navigateToProfile: String?
    @State private var navigateToConversation: DMConversation?

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack {
                Spacer()
                Text("Messages")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }
            .frame(height: 44)
            .background(Theme.bg)

            List {
            ForEach(mockConversations) { conversation in
                NavigationLink(value: conversation) {
                    ConversationListRow(
                        avatar: AnyView(AvatarHelper.avatarView(for: conversation.username, size: 60)),
                        title: conversation.username,
                        preview: conversation.lastMessage,
                        timestamp: conversation.timestamp,
                        isUnread: conversation.isUnread,
                        isSent: conversation.isSent,
                        onProfileTap: {
                            navigateToProfile = conversation.username
                        }
                    )
                }
                .listRowBackground(Theme.bg)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        }
        .navigationDestination(for: DMConversation.self) { conversation in
            ConversationView(conversation: conversation)
        }
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
    }

    private var mockConversations: [DMConversation] {
        [
            DMConversation(
                username: "u/CryptoWhale",
                lastMessage: "Did you see that $BTC pump?",
                timestamp: Date().addingTimeInterval(-300), // 5 min ago
                isUnread: true,
                isSent: false
            ),
            DMConversation(
                username: "u/AnonFin",
                lastMessage: "What's your $AAPL play?",
                timestamp: Date().addingTimeInterval(-120), // 2 min ago
                isUnread: true,
                isSent: false
            ),
            DMConversation(
                username: "u/ByteWhale",
                lastMessage: "Thanks for the tip!",
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isUnread: false,
                isSent: false
            ),
            DMConversation(
                username: "u/SpiceTrader",
                lastMessage: "See you tomorrow",
                timestamp: Date().addingTimeInterval(-7200), // 2 hours ago
                isUnread: false,
                isSent: true
            )
        ]
    }
}

// DM Conversation model
struct DMConversation: Identifiable, Hashable {
    let id = UUID()
    let username: String
    let lastMessage: String
    let timestamp: Date
    let isUnread: Bool
    let isSent: Bool
}

private struct ChatLockedView: View {
    let requiredTier: String
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill").font(.system(size: 48)).foregroundStyle(Theme.accentMuted)
            Text("Chat Locked").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
            Text("Reach \(requiredTier) tier to unlock DMs.")
                .font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
            NavigationLink("See How To Rank Up") {
                LeaderboardView()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accentMuted)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.bg)
        .navigationTitle("Messages")
    }
}

private struct TabBarButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(isSelected ? Theme.accentMuted : Theme.textSecondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
    }
}

