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
            .safeAreaInset(edge: .top, spacing: 0) {
                if !isDrawerOpen {
                    VStack(spacing: 0) {
                        HStack {
                            // Profile photo button
                            Button(action: { withAnimation(.spring()) { isDrawerOpen = true } }) {
                                AvatarHelper.avatarView(for: "u/You", size: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.divider, lineWidth: 2)
                                    )
                            }
                            .padding(.leading, 16)

                            Spacer()

                            // Title in center
                            Text("Home Feed")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.textPrimary)

                            Spacer()

                            // Search button
                            Button(action: { path.append(HomeDestination.search) }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundStyle(Theme.textPrimary)
                                    .frame(width: 32, height: 32)
                            }
                            .padding(.trailing, 16)
                        }
                        .frame(height: 44)

                        // Separator line
                        Rectangle()
                            .fill(
                                AppSettings.shared.isDarkMode
                                    ? Theme.accentMuted.opacity(0.3)
                                    : Color(red: 0.18, green: 0.50, blue: 0.22).opacity(0.3)
                            )
                            .frame(height: 1)
                    }
                    .background(Theme.bg)
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
        let blurView = UIVisualEffectView(effect: blurEffect)

        appearance.backgroundEffect = blurEffect
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
}

private struct FeedDemo: View {
    @State private var navigateToProfile: String?
    @State private var showPostTypeDrawer = false
    @Environment(\.tabSelection) private var tabSelection

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink { PostDetailView(post: Post(author: User(handle: "u/CryptoWhale", avatar: "person", score: 0), text: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto", upvotes: 8742, comments: [], reposts: 1205, timestamp: Date().addingTimeInterval(-1800))) } label: {
                        FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/CryptoWhale", size: 44)), username: "u/CryptoWhale", text: TickerFormat.normalizePrefixes(in: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto"), upvoteScore: 8742, comments: "1.2k", reposts: "543", timestamp: Date().addingTimeInterval(-1800), onProfileTap: {
                            navigateToProfile = "u/CryptoWhale"
                        })
                    }
                    NavigationLink { PostDetailView(post: Post(author: User(handle: "u/ByteWhale", avatar: "person", score: 0), text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading", upvotes: 5300, comments: [], reposts: 412, timestamp: Date().addingTimeInterval(-10800))) } label: {
                        FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/ByteWhale", size: 44)), username: "u/ByteWhale", text: TickerFormat.normalizePrefixes(in: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading"), upvoteScore: 5300, comments: "412", reposts: "87", timestamp: Date().addingTimeInterval(-10800), onProfileTap: {
                            navigateToProfile = "u/ByteWhale"
                        })
                    }
                    NavigationLink { PostDetailView(post: Post(author: User(handle: "u/QuantJunkie", avatar: "person.circle.fill", score: 0), text: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement", upvotes: 856, comments: [], reposts: 112, timestamp: Date().addingTimeInterval(-7200))) } label: {
                        FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/QuantJunkie", size: 44)), username: "u/QuantJunkie", text: TickerFormat.normalizePrefixes(in: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement"), upvoteScore: 856, comments: "89", reposts: "43", timestamp: Date().addingTimeInterval(-7200), onProfileTap: {
                            navigateToProfile = "u/QuantJunkie"
                        })
                    }
                    NavigationLink { PostDetailView(post: Post(author: User(handle: "u/ByteNomad", avatar: "person.circle", score: 0), text: "I can't tell if I'm working for money or if money's working me.", upvotes: 530, comments: [], reposts: 642, timestamp: Date().addingTimeInterval(-3600))) } label: {
                        FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/ByteNomad", size: 44)), username: "u/ByteNomad", text: TickerFormat.normalizePrefixes(in: "I can't tell if I'm working for money or if money's working me."), upvoteScore: 530, comments: "1.2k", reposts: "642", onProfileTap: {
                            navigateToProfile = "u/ByteNomad"
                        })
                    }
                }
            }
            .background(Theme.bg)

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

