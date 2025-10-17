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
                #if os(iOS)
                .toolbarVisibility(.visible, for: .tabBar)
                #endif
            }
            #if os(iOS)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarVisibility(isDrawerOpen ? .hidden : .visible, for: .tabBar)
            #endif
            .safeAreaInset(edge: .top, spacing: 0) {
                if !isDrawerOpen {
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
                    .background(Theme.bg)
                }
            }
        }
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
        TabView(selection: $selectedTab) {
            HomeWithDrawer()
                .tabItem { Image(systemName: "house") }
                .environment(player)
                .tag(0)

            NavigationStack {
                if canChat { MessagesDemo() } else { ChatLockedView(requiredTier: player.minTierForChat) }
            }
            .tabItem { Image(systemName: "envelope") }
            .environment(player)
            .tag(1)

            NavigationStack { NotificationsView() }
                .tabItem { Image(systemName: "bell") }
                .environment(player)
                .tag(2)

            NavigationStack { ArenaListView() }
                .tabItem { Image(systemName: "chart.line.uptrend.xyaxis") }
                .environment(player)
                .tag(3)

            NavigationStack { LeaderboardView() }
                .tabItem { Image(systemName: "trophy") }
                .environment(player)
                .tag(4)
        }
        .tint(Theme.accentMuted)
        .onAppear { configureTabBar() }
        .background(Theme.bg.ignoresSafeArea())
        .environment(player)
        .environment(\.tabSelection, $selectedTab)
        .owlRefreshEnabled()
    }

    private var canChat: Bool {
        // gate chat if below required tier
        guard let requiredIndex = model.tiers.firstIndex(where: { $0.name == player.minTierForChat }),
              let currentIndex = model.tiers.firstIndex(where: { $0.contains(player.profile.netWorthUSD) }) else { return true }
        return currentIndex >= requiredIndex
    }

    private func configureTabBar() {
        #if os(iOS)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.bg)
        appearance.shadowColor = UIColor(Theme.divider)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
}

private struct FeedDemo: View {
    @State private var navigateToProfile: String?
    @Environment(\.tabSelection) private var tabSelection

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                NavigationLink { PostDetailView(post: Post(author: User(handle: "u/CryptoWhale", avatar: "person", score: 0), text: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto", upvotes: 8742, comments: [], reposts: 1205, timestamp: Date().addingTimeInterval(-1800))) } label: {
                    FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/CryptoWhale", size: 44)), username: "CryptoWhale", text: TickerFormat.normalizePrefixes(in: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive. This bull run is just getting started. #Bitcoin #Crypto"), upvoteScore: 8742, comments: "1.2k", reposts: "543", timestamp: Date().addingTimeInterval(-1800), onProfileTap: {
                        navigateToProfile = "u/CryptoWhale"
                    })
                }
                NavigationLink { PostDetailView(post: Post(author: User(handle: "u/ByteWhale", avatar: "person", score: 0), text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading", upvotes: 5300, comments: [], reposts: 412, timestamp: Date().addingTimeInterval(-10800))) } label: {
                    FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/ByteWhale", size: 44)), username: "ByteWhale", text: TickerFormat.normalizePrefixes(in: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading"), upvoteScore: 5300, comments: "412", reposts: "87", timestamp: Date().addingTimeInterval(-10800), onProfileTap: {
                        navigateToProfile = "u/ByteWhale"
                    })
                }
                NavigationLink { PostDetailView(post: Post(author: User(handle: "u/QuantJunkie", avatar: "person.circle.fill", score: 0), text: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement", upvotes: 856, comments: [], reposts: 112, timestamp: Date().addingTimeInterval(-7200))) } label: {
                    FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/QuantJunkie", size: 44)), username: "QuantJunkie", text: TickerFormat.normalizePrefixes(in: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement"), upvoteScore: 856, comments: "89", reposts: "43", timestamp: Date().addingTimeInterval(-7200), onProfileTap: {
                        navigateToProfile = "u/QuantJunkie"
                    })
                }
                NavigationLink { PostDetailView(post: Post(author: User(handle: "u/ByteNomad", avatar: "person.circle", score: 0), text: "I can't tell if I'm working for money or if money's working me.", upvotes: 530, comments: [], reposts: 642, timestamp: Date().addingTimeInterval(-3600))) } label: {
                    FeedRow(avatar: AnyView(AvatarHelper.avatarView(for: "u/ByteNomad", size: 44)), username: "ByteNomad", text: TickerFormat.normalizePrefixes(in: "I can't tell if I'm working for money or if money's working me."), upvoteScore: 530, comments: "1.2k", reposts: "642", onProfileTap: {
                        navigateToProfile = "u/ByteNomad"
                    })
                }
            }
        }
        .background(Theme.bg)
        .navigationTitle("Home Feed")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
    }
}

private struct MessagesDemo: View {
    @State private var navigateToProfile: String?
    @State private var navigateToConversation: DMConversation?

    var body: some View {
        List {
            ForEach(mockConversations) { conversation in
                NavigationLink(value: conversation) {
                    ConversationListRow(
                        avatar: AnyView(AvatarHelper.avatarView(for: conversation.username, size: 48)),
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
        .navigationTitle("Messages")
        .navigationDestination(for: DMConversation.self) { conversation in
            ConversationView(conversation: conversation)
        }
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
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

