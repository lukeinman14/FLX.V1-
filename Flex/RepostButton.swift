import SwiftUI

struct RepostButton: View {
    let initialCount: String
    let postText: String
    let postAuthor: String
    let postLikes: Int
    let postComments: Int
    let postTimestamp: Date

    @ObservedObject private var repostManager = RepostManager.shared
    @State private var isReposted = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isReposted.toggle()

                if isReposted {
                    // Add repost to user's profile
                    let repostCount = Int(initialCount.filter { $0.isNumber }) ?? 0
                    repostManager.addRepost(
                        author: postAuthor,
                        text: postText,
                        likes: postLikes,
                        reposts: repostCount,
                        comments: postComments,
                        timestamp: postTimestamp
                    )
                } else {
                    // Remove repost from user's profile
                    repostManager.removeRepost(text: postText, author: postAuthor)
                }
            }
        }) {
            HStack(spacing: 4) {
                Image(systemName: isReposted ? "arrow.2.squarepath.fill" : "arrow.2.squarepath")
                    .font(.system(size: 16, weight: .medium))
                Text(initialCount)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(isReposted ? .green : Theme.textSecondary)
        }
        .buttonStyle(.plain)
        .onAppear {
            isReposted = repostManager.isReposted(text: postText, author: postAuthor)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        RepostButton(
            initialCount: "234",
            postText: "$BTC breaking new highs!",
            postAuthor: "u/CryptoWhale",
            postLikes: 1500,
            postComments: 42,
            postTimestamp: Date()
        )
        RepostButton(
            initialCount: "1.2k",
            postText: "Testing repost functionality",
            postAuthor: "u/TestUser",
            postLikes: 2400,
            postComments: 156,
            postTimestamp: Date()
        )
    }
    .padding()
    .background(Theme.bg)
    .preferredColorScheme(.dark)
}
