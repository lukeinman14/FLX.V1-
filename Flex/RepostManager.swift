import SwiftUI
import Combine

// Represents a reposted post on user's profile
struct RepostedPost: Identifiable, Hashable {
    let id = UUID()
    let originalAuthor: String
    let repostedBy: String // The user who reposted it
    let text: String
    let likes: Int
    let reposts: Int
    let comments: Int
    let timestamp: Date
    let repostedAt: Date

    init(originalAuthor: String, repostedBy: String = "u/You", text: String, likes: Int, reposts: Int, comments: Int, originalTimestamp: Date, repostedAt: Date = Date()) {
        self.originalAuthor = originalAuthor
        self.repostedBy = repostedBy
        self.text = text
        self.likes = likes
        self.reposts = reposts
        self.comments = comments
        self.timestamp = originalTimestamp
        self.repostedAt = repostedAt
    }
}

// Combined post type for profile timeline
enum ProfilePost: Identifiable, Hashable {
    case original(ProfileMockPost)
    case repost(RepostedPost)

    var id: UUID {
        switch self {
        case .original(let post):
            return UUID() // Generate unique ID based on post
        case .repost(let post):
            return post.id
        }
    }

    var displayTimestamp: Date {
        switch self {
        case .original(let post):
            return post.timestamp
        case .repost(let post):
            return post.repostedAt
        }
    }

    var text: String {
        switch self {
        case .original(let post):
            return post.text
        case .repost(let post):
            return post.text
        }
    }

    var likes: Int {
        switch self {
        case .original(let post):
            return post.likes
        case .repost(let post):
            return post.likes
        }
    }

    var comments: Int {
        switch self {
        case .original(let post):
            return post.comments
        case .repost(let post):
            return post.comments
        }
    }

    var reposts: Int {
        switch self {
        case .original(let post):
            return post.reposts
        case .repost(let post):
            return post.reposts
        }
    }
}

// Global singleton to manage reposts across the app
class RepostManager: ObservableObject {
    static let shared = RepostManager()

    @Published var repostedPosts: [RepostedPost] = []

    private init() {}

    func addRepost(author: String, text: String, likes: Int, reposts: Int, comments: Int, timestamp: Date, repostedBy: String = "u/You") {
        let repost = RepostedPost(
            originalAuthor: author,
            repostedBy: repostedBy,
            text: text,
            likes: likes,
            reposts: reposts,
            comments: comments,
            originalTimestamp: timestamp
        )
        repostedPosts.insert(repost, at: 0) // Add to beginning (most recent)
    }

    func removeRepost(text: String, author: String) {
        repostedPosts.removeAll { $0.text == text && $0.originalAuthor == author }
    }

    func isReposted(text: String, author: String) -> Bool {
        repostedPosts.contains { $0.text == text && $0.originalAuthor == author }
    }
}
