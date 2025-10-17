import SwiftUI

struct FeedRow: View {
    var avatar: AnyView
    var username: String
    var text: String
    var upvoteScore: Int
    var comments: String
    var reposts: String
    var timestamp: Date = Date()
    var onProfileTap: (() -> Void)? = nil
    var onCommentTap: (() -> Void)? = nil

    private let stockTickers: Set<String>
    @State private var showShareSheet = false

    init(avatar: AnyView, username: String, text: String, upvoteScore: Int, comments: String, reposts: String, timestamp: Date = Date(), onProfileTap: (() -> Void)? = nil, onCommentTap: (() -> Void)? = nil) {
        self.avatar = avatar
        self.username = username
        self.text = text
        self.upvoteScore = upvoteScore
        self.comments = comments
        self.reposts = reposts
        self.timestamp = timestamp
        self.onProfileTap = onProfileTap
        self.onCommentTap = onCommentTap
        self.stockTickers = PostTextParser.extractStockTickers(from: text)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with avatar, username, and timestamp
            HStack(alignment: .top, spacing: 12) {
                Button(action: {
                    onProfileTap?()
                }) {
                    avatar
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(username)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    // Rich text with stock ticker highlighting and embedded charts
                    RichPostTextView(text: text)
                }

                Spacer()

                Text(timestamp.timeAgo())
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
            }

            // Chart preview if post contains stock ticker
            if let firstTicker = stockTickers.first {
                CompactChartPreview(symbol: firstTicker)
                    .padding(.top, 8)
            }

            // Engagement buttons
            HStack(spacing: 20) {
                // Vote buttons
                VoteButton(score: upvoteScore)

                // Comment
                Button(action: {
                    onCommentTap?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16, weight: .medium))
                        Text(comments)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)

                // Repost
                RepostButton(
                    initialCount: reposts,
                    postText: text,
                    postAuthor: username,
                    postLikes: upvoteScore,
                    postComments: Int(comments) ?? 0,
                    postTimestamp: timestamp
                )

                Spacer()

                // Share
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            Divider().background(Theme.divider)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Theme.bg)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(
                postURL: "https://flex.app/post/\(username)/\(UUID().uuidString)",
                postText: text
            )
        }
    }
}
