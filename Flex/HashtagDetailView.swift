import SwiftUI

struct HashtagDetailView: View {
    let hashtag: String
    @State private var navigateToProfile: String?
    @State private var showShareSheet = false
    @State private var selectedPost: MockHashtagPost?
    @State private var navigateToPost: MockHashtagPost?

    // Mock posts containing this hashtag
    private var relatedPosts: [MockHashtagPost] {
        MockHashtagPost.mockPosts(for: hashtag)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(relatedPosts) { post in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Button(action: {
                                navigateToProfile = post.username
                            }) {
                                AvatarHelper.avatarView(for: post.username, size: 36)
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.username.withoutUsernamePrefix)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Theme.textPrimary)
                            }

                            Spacer()

                            Text(post.timestamp.timeAgo())
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
                        }

                        Text(post.text)
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.textPrimary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .onTapGesture {
                                navigateToPost = post
                            }

                        // Engagement buttons
                        HStack(spacing: 20) {
                            // Vote buttons
                            VoteButton(score: post.upvotes)

                            // Comment
                            Button(action: {
                                navigateToPost = post
                            }) {
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
                                postAuthor: post.username,
                                postLikes: post.upvotes,
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
                    .padding(16)
                    .background(Theme.surface)

                    Divider().background(Theme.divider)
                }
            }
        }
        .background(Theme.bg)
        .navigationTitle("#\(hashtag)")
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
        .navigationDestination(item: $navigateToPost) { post in
            PostDetailView(post: Post(
                author: User(handle: post.username, avatar: "person", score: 0),
                text: post.text,
                upvotes: post.upvotes,
                comments: [],
                reposts: post.reposts,
                timestamp: post.timestamp
            ))
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .sheet(isPresented: $showShareSheet) {
            if let post = selectedPost {
                ShareSheet(
                    postURL: "https://flex.app/hashtag/\(hashtag)/\(post.id.uuidString)",
                    postText: post.text
                )
            }
        }
        #if os(iOS)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
    }
}

struct MockHashtagPost: Identifiable, Hashable {
    let id = UUID()
    let username: String
    let text: String
    let upvotes: Int
    let comments: Int
    let reposts: Int
    let timestamp: Date

    static func mockPosts(for hashtag: String) -> [MockHashtagPost] {
        switch hashtag.lowercased() {
        case "ai", "trading":
            return [
                MockHashtagPost(username: "u/ByteWhale", text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play? #AI #Trading", upvotes: 5300, comments: 412, reposts: 87, timestamp: Date().addingTimeInterval(-3600)),
                MockHashtagPost(username: "u/TechInvestor", text: "AI stocks are on fire this quarter. $NVDA, $MSFT, $GOOGL all printing. #AI #TechStocks", upvotes: 2890, comments: 234, reposts: 156, timestamp: Date().addingTimeInterval(-7200)),
                MockHashtagPost(username: "u/AlgoTrader", text: "My AI-powered trading bot just had its best month ever. Up 47%. #AI #Trading #AlgoTrading", upvotes: 3450, comments: 289, reposts: 234, timestamp: Date().addingTimeInterval(-10800)),
                MockHashtagPost(username: "u/MLEngineer", text: "The future of #AI in finance is incredible. Machine learning models are outperforming human traders.", upvotes: 1670, comments: 167, reposts: 98, timestamp: Date().addingTimeInterval(-14400))
            ]
        case "bitcoin", "crypto":
            return [
                MockHashtagPost(username: "u/CryptoWhale", text: "Stacking weekly DCA on dips. #Bitcoin #DCA", upvotes: 1200, comments: 214, reposts: 87, timestamp: Date().addingTimeInterval(-7200)),
                MockHashtagPost(username: "u/BTCMaximalist", text: "#Bitcoin is digital gold. Period. Don't overthink it.", upvotes: 2340, comments: 345, reposts: 189, timestamp: Date().addingTimeInterval(-10800)),
                MockHashtagPost(username: "u/HODLer", text: "Another day, another sats. #Bitcoin #HODL 💎🙌", upvotes: 890, comments: 76, reposts: 43, timestamp: Date().addingTimeInterval(-14400))
            ]
        case "technicalanalysis", "riskmanagement":
            return [
                MockHashtagPost(username: "u/QuantJunkie", text: "$NVDA RSI is already overbought. I'm trimming positions. #TechnicalAnalysis #RiskManagement", upvotes: 856, comments: 89, reposts: 43, timestamp: Date().addingTimeInterval(-7200)),
                MockHashtagPost(username: "u/ChartMaster", text: "Key support at 420. Breaking below could trigger sell-off. #TechnicalAnalysis #Trading", upvotes: 1450, comments: 134, reposts: 78, timestamp: Date().addingTimeInterval(-10800)),
                MockHashtagPost(username: "u/RiskManager", text: "Always size your positions properly. #RiskManagement is what separates winners from losers.", upvotes: 2100, comments: 187, reposts: 156, timestamp: Date().addingTimeInterval(-14400))
            ]
        default:
            return [
                MockHashtagPost(username: "u/User1", text: "Great discussion about #\(hashtag) today. Lots to think about.", upvotes: 456, comments: 34, reposts: 12, timestamp: Date().addingTimeInterval(-3600)),
                MockHashtagPost(username: "u/User2", text: "Here's my take on #\(hashtag) and why it matters for the future.", upvotes: 234, comments: 23, reposts: 8, timestamp: Date().addingTimeInterval(-7200))
            ]
        }
    }
}
