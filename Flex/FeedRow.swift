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
            // Header with avatar and username
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

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(username.withoutUsernamePrefix)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)

                        Spacer()

                        Text(timestamp.timeAgo())
                            .font(.system(size: 14))
                            .foregroundStyle(AppSettings.shared.isDarkMode ? Color(red: 0.1, green: 1.0, blue: 0.4) : Theme.textSecondary)
                            .padding(.trailing, 8)
                    }

                    // Rich text with stock ticker highlighting and embedded charts
                    RichPostTextView(text: text)
                        .padding(.trailing, 8)
                }
            }

            // Chart preview if post contains stock ticker
            if let firstTicker = stockTickers.first {
                CompactChartPreview(symbol: firstTicker)
                    .padding(.leading, 56)  // 44 (avatar width) + 12 (spacing)
                    .padding(.trailing, 8)
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
                .padding(.trailing, 8)
            }
            .padding(.leading, 56)  // 44 (avatar width) + 12 (spacing)

        }
        .padding(.horizontal, 4)
        .padding(.vertical, 16)
        .background(
            Group {
                if AppSettings.shared.isDarkMode {
                    Theme.surface
                } else {
                    ZStack {
                        // Bright white base background
                        Color.white.opacity(0.95)

                        // Subtle blur layer for glass effect
                        Color.clear
                            .background(.ultraThinMaterial)
                            .opacity(0.25)
                    }
                }
            }
        )
        .shadow(
            color: AppSettings.shared.isDarkMode ? Theme.accent.opacity(0.08) : Color.black.opacity(0.06),
            radius: 12,
            x: 0,
            y: 6
        )
        .shadow(
            color: AppSettings.shared.isDarkMode ? Theme.accent.opacity(0.04) : Color.black.opacity(0.04),
            radius: 4,
            x: 0,
            y: 2
        )
        .padding(.vertical, 8)
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(
                postURL: "https://flex.app/post/\(username)/\(UUID().uuidString)",
                postText: text
            )
        }
    }
}
