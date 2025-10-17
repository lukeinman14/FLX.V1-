import SwiftUI
import Foundation

struct HomeFeedView: View {
    var body: some View {
        NavigationStack {
            List(FlexMockData.posts) { post in
                NavigationLink(value: post) {
                    PostRow(post: post)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .navigationTitle("Home")
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Placeholder for search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(FlexTheme.secondaryText)
                    }
                }
                #else
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Placeholder for search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(FlexTheme.secondaryText)
                    }
                }
                #endif
            }
            .background(FlexTheme.background.ignoresSafeArea())
        }
        .navigationDestination(for: FlexPost.self) { post in
            FlexPostDetailView(post: post)
        }
    }
}

struct PostRow: View {
    let post: FlexPost

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 6) {
                Image(systemName: "arrowtriangle.up.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(FlexTheme.accent)
                Text("\(post.upvotes)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(FlexTheme.secondaryText)
            }
            .frame(width: 40)
            .padding(.top, 6)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 8) {
                    AsyncImage(url: URL(string: post.authorAvatarURL)) { image in
                        image.resizable()
                    } placeholder: {
                        Circle()
                            .fill(FlexTheme.secondaryBackground)
                    }
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())

                    Text(post.authorHandle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(FlexTheme.primaryText)

                    Spacer()
                }

                Text(TickerFormat.normalizePrefixes(in: post.text))
                    .font(.callout)
                    .foregroundColor(FlexTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                let tickers = PostTextParser.extractStockTickers(from: post.text)
                if let first = tickers.first {
                    NavigationLink { StockChatView(symbol: first) } label: {
                        MiniChartPreview(symbol: first)
                            .padding(.top, 6)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowtriangle.up.fill")
                        Text("\(post.upvotes)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "text.bubble")
                        Text("\(post.commentsCount)")
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.2.squarepath")
                        Text("\(post.repostsCount)")
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(FlexTheme.secondaryText)
            }
            .padding(12)
            .background(FlexTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.vertical, 6)
        .listRowSeparator(.hidden)
        .background(FlexTheme.background)
    }
}

// MARK: - Supporting Views and Models

struct FlexPostDetailView: View {
    let post: FlexPost

    var body: some View {
        Text("Detail View for \(post.authorHandle)'s post")
            .navigationTitle("Post")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .foregroundColor(FlexTheme.primaryText)
            .background(FlexTheme.background.ignoresSafeArea())
    }
}

struct FlexPost: Identifiable, Hashable {
    let id: UUID
    let authorHandle: String
    let authorAvatarURL: String
    let text: String
    let upvotes: Int
    let commentsCount: Int
    let repostsCount: Int
}

struct FlexMockData {
    static let posts: [FlexPost] = [
        FlexPost(id: UUID(),
                 authorHandle: "@alice",
                 authorAvatarURL: "https://i.pravatar.cc/150?img=1",
                 text: "This is a sample post from Alice. Loving the new SwiftUI features!",
                 upvotes: 45,
                 commentsCount: 12,
                 repostsCount: 4),
        FlexPost(id: UUID(),
                 authorHandle: "@bob",
                 authorAvatarURL: "https://i.pravatar.cc/150?img=2",
                 text: "Check out my latest blog post about Combine and its power.",
                 upvotes: 32,
                 commentsCount: 8,
                 repostsCount: 2),
        FlexPost(id: UUID(),
                 authorHandle: "@charlie",
                 authorAvatarURL: "https://i.pravatar.cc/150?img=3",
                 text: "Does anyone have tips for optimizing Swift code for performance?",
                 upvotes: 18,
                 commentsCount: 5,
                 repostsCount: 1)
    ]
}

// MARK: - FlexTheme Colors

enum FlexTheme {
    static let background = Color(red: 18/255, green: 18/255, blue: 18/255)
    static let cardBackground = Color(red: 30/255, green: 30/255, blue: 30/255)
    static let primaryText = Color.white
    static let secondaryText = Color(white: 0.7)
    static let secondaryBackground = Color(red: 50/255, green: 50/255, blue: 50/255)
    static let accent = Color.blue
}
