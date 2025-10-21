import SwiftUI

struct MyProfileView: View {
    @Environment(PlayerState.self) private var player
    @Environment(\.dismiss) private var dismiss
    private let model = GamificationModel.demo
    private let userDataManager = UserDataManager.shared

    @State private var selectedTab: ProfileTab = .thoughts
    @State private var followersCount: Int = 1005
    @State private var followingCount: Int = 350
    @State private var showShareSheet = false
    @State private var selectedPost: MockPost?
    @State private var navigateToProfile: String?
    @State private var navigateToPost: MockPost?
    @StateObject private var repostManager = RepostManager.shared

    enum ProfileTab: String, CaseIterable {
        case thoughts = "Thoughts"
        case replies = "Replies"
        case media = "Media"
    }

    var body: some View {
        let user = player.profile
        let currentTier = model.currentTier(for: user)

        ScrollView {
            VStack(spacing: 0) {
                spaceBannerSection
                profileInfoSection(user: user, tier: currentTier)
                tabNavigation
                contentSection
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        #if os(iOS)
        .ignoresSafeArea(edges: .top)
        #endif
        .sheet(isPresented: $showShareSheet) {
            if let post = selectedPost {
                ShareSheet(
                    postURL: "https://flex.app/profile/\(player.profile.username)/\(UUID().uuidString)",
                    postText: post.text
                )
            }
        }
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
        .navigationDestination(item: $navigateToPost) { post in
            PostDetailView(post: Post(
                author: User(handle: player.profile.username, avatar: "person", score: 0),
                text: post.text,
                upvotes: post.likes,
                comments: [],
                reposts: post.reposts,
                timestamp: post.timestamp
            ))
        }
        #if os(iOS)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
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
                .padding(.top, 44) // Account for status bar
                Spacer()
            }
        }
        .clipped()
    }

    private func profileInfoSection(user: UserProfile, tier: Tier?) -> some View {
        VStack(spacing: 16) {
            // Profile picture - positioned to overlap banner
            VStack(spacing: 0) {
                // Large circular profile picture with CryptoPunk avatar
                AvatarHelper.avatarView(for: user.username, size: 120)
                    .overlay(
                        Circle()
                            .stroke(.white, lineWidth: 4)
                    )
                    .offset(y: -60) // Overlap the banner
                
                VStack(spacing: 12) {
                    // Username with verification checkmark
                    HStack(spacing: 8) {
                        Text(user.username.withoutUsernamePrefix)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.blue)
                    }
                    
                    // Bio text
                    Text("alright, alright, alright")
                        .font(.system(size: 16))
                        .foregroundStyle(.white) // White text for bio
                        .multilineTextAlignment(.center)
                    
                    // Financial data row
                    HStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Net Worth")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white) // White text
                            Text(UserDataManager.shared.formatNetWorth(user.netWorthUSD))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white) // White text
                        }

                        Rectangle()
                            .fill(Theme.divider)
                            .frame(width: 1, height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tier")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white) // White text
                            Text(model.currentTier(for: user)?.name.uppercased() ?? "UNRANKED")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white) // White text
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
                .offset(y: -40) // Move up to account for overlapping profile pic
            }
        }
        .padding(.horizontal, 16)
        .background(Theme.bg)
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
        .background(Theme.bg)
        .overlay(
            Rectangle()
                .fill(Theme.divider)
                .frame(height: 1),
            alignment: .bottom
        )
        .offset(y: -16)
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
        .offset(y: -16)
    }

    // Combined timeline of original posts and reposts, sorted chronologically
    private var combinedTimeline: [ProfilePost] {
        var timeline: [ProfilePost] = []

        // Add original posts
        for post in mockPosts {
            timeline.append(.original(ProfileMockPost(
                text: post.text,
                likes: post.likes,
                reposts: post.reposts,
                comments: post.comments,
                timestamp: post.timestamp
            )))
        }

        // Add reposts (only those reposted by the current user)
        for repost in repostManager.repostedPosts where repost.repostedBy == player.profile.username {
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
                post: MockPost(
                    text: originalPost.text,
                    likes: originalPost.likes,
                    reposts: originalPost.reposts,
                    comments: originalPost.comments,
                    timestamp: originalPost.timestamp
                ),
                isRepost: false,
                originalAuthor: nil,
                displayTimestamp: item.displayTimestamp
            )
        case .repost(let repostedPost):
            postContent(
                post: MockPost(
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
    private func postContent(post: MockPost, isRepost: Bool, originalAuthor: String?, displayTimestamp: Date) -> some View {
        Button(action: {
            navigateToPost = post
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Repost indicator
                if isRepost {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.2.squarepath")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.textSecondary)
                        Text("You reposted")
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

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(author.withoutUsernamePrefix)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)

                                Spacer()

                                Text(displayTimestamp.timeAgo())
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4))
                                    .padding(.trailing, 8)
                            }

                            // Rich text with highlighting for tickers and hashtags
                            RichPostTextView(text: post.text)
                                .padding(.trailing, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        // For original posts, show profile picture
                        AvatarHelper.avatarView(for: player.profile.username, size: 40)
                            .overlay(Circle().stroke(Theme.divider, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(player.profile.username.withoutUsernamePrefix)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)

                                Spacer()

                                Text(displayTimestamp.timeAgo())
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4))
                                    .padding(.trailing, 8)
                            }

                            // Rich text with highlighting for tickers and hashtags
                            RichPostTextView(text: post.text)
                                .padding(.trailing, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

            // Chart preview if post contains stock ticker
            if let firstTicker = PostTextParser.extractStockTickers(from: post.text).first {
                CompactChartPreview(symbol: firstTicker)
                    .padding(.leading, 52)  // 40 (avatar width) + 12 (spacing)
                    .padding(.trailing, 8)
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
                    postAuthor: isRepost ? (originalAuthor ?? player.profile.username) : player.profile.username,
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
                .padding(.trailing, 8)
            }
            .padding(.leading, 52)  // 40 (avatar width) + 12 (spacing)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 4)
        .padding(.vertical, 16)
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

    private var mockPosts: [MockPost] {
        [
            MockPost(text: "Just hit my $AAPL target. Taking profits and waiting for the next dip. Patience pays off in this market. #Apple #ProfitTaking", likes: 1876, reposts: 234, comments: 127, timestamp: Date().addingTimeInterval(-1800)),
            MockPost(text: "$NVDA momentum is insane right now. Heavy volume and IV spike could setup for gamma squeeze. #AI #Trading", likes: 5300, reposts: 412, comments: 298, timestamp: Date().addingTimeInterval(-3600)),
            MockPost(text: "Stacking weekly DCA on dips. #Bitcoin #DCA", likes: 1200, reposts: 87, comments: 214, timestamp: Date().addingTimeInterval(-7200)),
            MockPost(text: "$TSLA breaking out of consolidation. Could see 300 if momentum holds. #Tesla #ElonMusk #EV", likes: 945, reposts: 187, comments: 156, timestamp: Date().addingTimeInterval(-10800)),
            MockPost(text: "Rebalancing 70/30 portfolio. Risk management is everything. #Investing #PortfolioManagement", likes: 692, reposts: 31, comments: 89, timestamp: Date().addingTimeInterval(-14400))
        ]
    }
}

struct MockPost: Hashable {
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
    @Previewable @State var player = PlayerState(profile: UserProfile(username: "u/You", netWorthUSD: 8200))
    return NavigationStack { MyProfileView().environment(player) }
        .preferredColorScheme(.dark)
}
