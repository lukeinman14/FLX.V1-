import SwiftUI

struct TickerDetailView: View {
    let symbol: String
    @StateObject private var api = StockAPIService.shared
    @State private var navigateToProfile: String?
    @State private var showShareSheet = false
    @State private var selectedPost: MockTickerPost?
    @State private var navigateToPost: MockTickerPost?

    // Mock posts containing this ticker
    private var relatedPosts: [MockTickerPost] {
        MockTickerPost.mockPosts(for: symbol)
    }

    // Get full company/asset name for ticker
    private var fullAssetName: String {
        switch symbol.uppercased() {
        case "NVDA": return "NVIDIA Corporation"
        case "AAPL": return "Apple Inc."
        case "TSLA": return "Tesla, Inc."
        case "MSFT": return "Microsoft Corporation"
        case "GOOGL": return "Alphabet Inc."
        case "AMZN": return "Amazon.com, Inc."
        case "META": return "Meta Platforms, Inc."
        case "BTC": return "Bitcoin"
        case "ETH": return "Ethereum"
        default: return symbol.uppercased()
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Chart at the top
                if let stockData = api.stockCache[symbol] {
                    StockChartView(stockData: stockData)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                } else {
                    // Loading state
                    VStack {
                        ProgressView()
                            .tint(Theme.accentMuted)
                        Text("Loading chart...")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                }

                // Section header for related posts
                HStack {
                    Text("Related Posts")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

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
        .navigationTitle(fullAssetName)
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
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
        .task {
            await api.fetchStockData(symbol: symbol)
        }
        .sheet(isPresented: $showShareSheet) {
            if let post = selectedPost {
                ShareSheet(
                    postURL: "https://flex.app/ticker/\(symbol)/\(post.id.uuidString)",
                    postText: post.text
                )
            }
        }
    }
}

struct MockTickerPost: Identifiable, Hashable {
    let id = UUID()
    let username: String
    let text: String
    let upvotes: Int
    let comments: Int
    let reposts: Int
    let timestamp: Date

    static func mockPosts(for symbol: String) -> [MockTickerPost] {
        switch symbol.uppercased() {
        case "NVDA":
            return [
                MockTickerPost(username: "u/ByteWhale", text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play?", upvotes: 5300, comments: 412, reposts: 87, timestamp: Date().addingTimeInterval(-3600)),
                MockTickerPost(username: "u/QuantJunkie", text: "$NVDA RSI is already overbought. I'm trimming positions.", upvotes: 856, comments: 89, reposts: 43, timestamp: Date().addingTimeInterval(-7200)),
                MockTickerPost(username: "u/ChipInvestor", text: "Just loaded up on $NVDA calls. AI isn't slowing down anytime soon 🚀", upvotes: 1240, comments: 156, reposts: 67, timestamp: Date().addingTimeInterval(-10800)),
                MockTickerPost(username: "u/TechTrader", text: "$NVDA earnings next week. Expecting a beat but watching for guidance closely.", upvotes: 2100, comments: 234, reposts: 112, timestamp: Date().addingTimeInterval(-14400))
            ]
        case "AAPL":
            return [
                MockTickerPost(username: "u/AppleFan", text: "Just hit my $AAPL target. Taking profits and waiting for the next dip. Patience pays off in this market.", upvotes: 1876, comments: 127, reposts: 234, timestamp: Date().addingTimeInterval(-1800)),
                MockTickerPost(username: "u/ValueSeeker", text: "$AAPL looking solid at this level. Vision Pro could be the next catalyst.", upvotes: 945, comments: 78, reposts: 45, timestamp: Date().addingTimeInterval(-5400)),
                MockTickerPost(username: "u/DividendKing", text: "Adding more $AAPL to my dividend portfolio. Love that steady income.", upvotes: 673, comments: 56, reposts: 23, timestamp: Date().addingTimeInterval(-9000))
            ]
        case "TSLA":
            return [
                MockTickerPost(username: "u/ElonFollower", text: "$TSLA breaking out of consolidation. Could see 300 if momentum holds.", upvotes: 945, comments: 156, reposts: 187, timestamp: Date().addingTimeInterval(-10800)),
                MockTickerPost(username: "u/EVInvestor", text: "Cybertruck deliveries ramping up. Bullish on $TSLA for Q4.", upvotes: 1234, comments: 198, reposts: 156, timestamp: Date().addingTimeInterval(-14400)),
                MockTickerPost(username: "u/TechBull", text: "$TSLA FSD update is game-changing. This is the future.", upvotes: 2100, comments: 289, reposts: 267, timestamp: Date().addingTimeInterval(-18000))
            ]
        default:
            return [
                MockTickerPost(username: "u/Trader123", text: "Watching $\(symbol) closely. Interesting price action today.", upvotes: 456, comments: 34, reposts: 12, timestamp: Date().addingTimeInterval(-3600)),
                MockTickerPost(username: "u/Investor", text: "$\(symbol) looks like a good entry point. Adding to my position.", upvotes: 234, comments: 23, reposts: 8, timestamp: Date().addingTimeInterval(-7200))
            ]
        }
    }
}
