import SwiftUI

struct HomeFeedView: View {
    var body: some View {
        NavigationStack {
            List(MockData.posts) { post in
                NavigationLink(value: post) {
                    PostRow(post: post)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Placeholder for search action
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(FlexTheme.secondaryText)
                    }
                }
            }
            .background(FlexTheme.background.ignoresSafeArea())
        }
        .navigationDestination(for: Post.self) { post in
            PostDetailView(post: post)
        }
    }
}

struct PostRow: View {
    let post: Post

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

                Text(post.text)
                    .font(.callout)
                    .foregroundColor(FlexTheme.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

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

struct PostDetailView: View {
    let post: Post

    var body: some View {
        Text("Detail View for \(post.authorHandle)'s post")
            .navigationTitle("Post")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(FlexTheme.primaryText)
            .background(FlexTheme.background.ignoresSafeArea())
    }
}

struct Post: Identifiable, Hashable {
    let id: UUID
    let authorHandle: String
    let authorAvatarURL: String
    let text: String
    let upvotes: Int
    let commentsCount: Int
    let repostsCount: Int
}

struct MockData {
    static let posts: [Post] = [
        Post(id: UUID(),
             authorHandle: "@alice",
             authorAvatarURL: "https://i.pravatar.cc/150?img=1",
             text: "This is a sample post from Alice. Loving the new SwiftUI features!",
             upvotes: 45,
             commentsCount: 12,
             repostsCount: 4),
        Post(id: UUID(),
             authorHandle: "@bob",
             authorAvatarURL: "https://i.pravatar.cc/150?img=2",
             text: "Check out my latest blog post about Combine and its power.",
             upvotes: 32,
             commentsCount: 8,
             repostsCount: 2),
        Post(id: UUID(),
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
