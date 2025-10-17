import SwiftUI

struct PostDetailView: View {
    var post: Post
    @State private var comments: [Comment] = [
        Comment(author: MockData.users[1], text: "Agree — buying the dip.", upvotes: 45),
        Comment(author: MockData.users[2], text: "Rolling weeklies for premium.", upvotes: 23),
        Comment(author: MockData.users[3], text: "Careful, CPI tomorrow.", upvotes: 67)
    ]
    @State private var draft = ""
    @State private var navigateToProfile: String?
    @State private var navigateToReply: Comment?
    @State private var showShareSheet = false
    @State private var navigateToTicker: String?

    // Extract stock tickers from the post text
    private var stockTickers: Set<String> {
        PostTextParser.extractStockTickers(from: post.text)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top, spacing: 12) {
                            Button(action: {
                                navigateToProfile = post.author.handle
                            }) {
                                AvatarHelper.avatarView(for: post.author.handle, size: 44)
                            }
                            .buttonStyle(.plain)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(post.author.handle.withoutUsernamePrefix)
                                    .font(Theme.headingFont())
                                    .foregroundStyle(Theme.textPrimary)
                            }

                            Spacer()

                            Text(post.timestamp.timeAgo())
                                .font(.system(size: 14))
                                .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
                        }

                        Text(post.text).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)

                        // Chart preview if post contains stock ticker
                        if let firstTicker = stockTickers.first {
                            VStack(spacing: 12) {
                                CompactChartPreview(symbol: firstTicker)

                                // "View Chart" button
                                Button(action: {
                                    navigateToTicker = firstTicker
                                }) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("View Chart")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundStyle(Theme.accentMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Theme.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Theme.accentMuted.opacity(0.3), lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 12)
                        }

                        // Post engagement buttons
                        HStack(spacing: 20) {
                            VoteButton(score: post.upvotes)

                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "bubble.left")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("\(comments.count)")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundStyle(Theme.textSecondary)
                            }
                            .buttonStyle(.plain)

                            RepostButton(
                                initialCount: "\(post.reposts)",
                                postText: post.text,
                                postAuthor: post.author.handle,
                                postLikes: post.upvotes,
                                postComments: post.comments.count,
                                postTimestamp: post.timestamp
                            )

                            Spacer()

                            Button(action: {
                                showShareSheet = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

                    Divider().background(Theme.divider)

                    // Replies section header
                    HStack {
                        Text("Replies")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.textPrimary)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    ForEach(comments) { c in
                        Button(action: {
                            navigateToReply = c
                        }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {
                                        navigateToProfile = c.author.handle
                                    }) {
                                        AvatarHelper.avatarView(for: c.author.handle, size: 32)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(c.author.handle.withoutUsernamePrefix)
                                            .font(Theme.smallFont())
                                            .foregroundStyle(Theme.accentMuted)
                                        Text(c.text).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                                    }

                                    Spacer()

                                    Text(c.timestamp.timeAgo())
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green timestamp
                                }

                                // Comment engagement buttons
                                HStack(spacing: 16) {
                                    VoteButton(score: c.upvotes)

                                    Button(action: {
                                        navigateToReply = c
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "bubble.left")
                                                .font(.system(size: 14, weight: .medium))
                                            Text("Reply")
                                                .font(.system(size: 13, weight: .medium))
                                        }
                                        .foregroundStyle(Theme.textSecondary)
                                    }
                                    .buttonStyle(.plain)

                                    Spacer()
                                }
                                .padding(.leading, 44)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Theme.surface)
                            .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            inputBar
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Post")
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
        .navigationDestination(item: $navigateToReply) { comment in
            PostDetailView(post: Post(
                author: comment.author,
                text: comment.text,
                upvotes: comment.upvotes,
                comments: [],
                reposts: 0,
                timestamp: Date()
            ))
        }
        .navigationDestination(item: $navigateToTicker) { ticker in
            TickerDetailView(symbol: ticker)
        }
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(
                postURL: "https://flex.app/post/\(post.author.handle)/\(UUID().uuidString)",
                postText: post.text
            )
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Add a reply", text: $draft)
                .textFieldStyle(.plain)
                .font(Theme.bodyFont())
                .foregroundStyle(Theme.textPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(Theme.surface)
                        .overlay(Capsule().stroke(Theme.divider, lineWidth: 1))
                )
            Button {
                if !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    comments.append(Comment(author: User(handle: "u/You", avatar: "person.circle", score: 0), text: draft))
                    draft.removeAll()
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Theme.accentMuted)
                    .font(.system(size: 22))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.bg.opacity(0.9).ignoresSafeArea(edges: .bottom))
    }
}

#Preview {
    NavigationStack {
        PostDetailView(post: Post(author: MockData.users[0], text: "Every dip feels scary, but wealth is built in the red, not the green.", upvotes: 123, comments: [], reposts: 10, timestamp: Date()))
    }
    .preferredColorScheme(.dark)
}
