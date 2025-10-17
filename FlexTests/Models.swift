import Foundation

struct User: Identifiable, Hashable {
    let id = UUID()
    var handle: String
    var avatar: String
    var score: Double
}

struct Comment: Identifiable, Hashable {
    let id = UUID()
    var author: User
    var text: String
    var upvotes: Int = 0
    var timestamp: Date = Date()
}

struct Post: Identifiable {
    let id = UUID()
    var author: User
    var text: String
    var upvotes: Int = 0
    var comments: [Comment] = []
    var reposts: Int = 0
    var timestamp: Date = Date()
}

struct ParsedPost: Identifiable {
    let id: UUID
    var author: User
    var text: String
    var upvotes: Int
    var comments: [Comment]
    var reposts: Int
    var timestamp: Date
    var stockTickers: Set<String>
    
    init(from post: Post) {
        self.id = post.id
        self.author = post.author
        self.text = post.text
        self.upvotes = post.upvotes
        self.comments = post.comments
        self.reposts = post.reposts
        self.timestamp = post.timestamp
        self.stockTickers = PostTextParser.extractStockTickers(from: post.text)
    }
}

struct DMThread: Identifiable {
    let id = UUID()
    var other: User
    var lastMessage: String
    var unreadCount: Int
}

struct Holding: Identifiable {
    let id = UUID()
    let symbol: String
    let amount: String
    let value: String
}

enum MockData {
    static let users: [User] = [
        User(handle: "u/AnonFin", avatar: "person.circle.fill", score: 2543.2),
        User(handle: "u/ByteWhale", avatar: "person.circle.fill", score: 1987.5),
        User(handle: "u/CryptoSage", avatar: "person.circle.fill", score: 1804.7),
        User(handle: "u/HashHound", avatar: "person.circle.fill", score: 1650.9)
    ]
    
    static let posts: [Post] = [
        Post(
            author: users[1], // u/ByteWhale
            text: "Watching $NVDA today. The momentum feels unreal — heavy volume and IV spike. Could be a setup for a gamma squeeze. What's everyone's play?",
            upvotes: 5300,
            comments: [
                Comment(author: users[2], text: "$NVDA RSI is already overbought. I'm trimming."),
                Comment(author: users[0], text: "Still early in the cycle. AI narrative hasn't peaked yet")
            ],
            reposts: 412,
            timestamp: Date().addingTimeInterval(-10800) // 3h ago
        ),
        Post(
            author: users[2], // u/CryptoSage
            text: "$NVDA RSI is already overbought. I'm trimming.",
            upvotes: 856,
            comments: [
                Comment(author: users[3], text: "Smart move!")
            ],
            reposts: 112,
            timestamp: Date().addingTimeInterval(-7200) // 2h ago
        ),
        Post(
            author: users[2],
            text: "Anyone tried the new staking platform?",
            upvotes: 76,
            comments: [
                Comment(author: users[3], text: "Yes, it’s great!")
            ],
            reposts: 9,
            timestamp: Date().addingTimeInterval(-900) // 15m ago
        ),
        Post(
            author: users[0],
            text: "Just hit my $AAPL target. Taking profits and waiting for the next dip. Patience pays off in this market.",
            upvotes: 1876,
            comments: [
                Comment(author: users[2], text: "Nice trade! What's your next target?")
            ],
            reposts: 234,
            timestamp: Date().addingTimeInterval(-1800) // 30m ago
        )
    ]
    
    static let threads: [DMThread] = [
        DMThread(
            other: users[3],
            lastMessage: "Did you check the latest token launch?",
            unreadCount: 2
        ),
        DMThread(
            other: users[2],
            lastMessage: "Thanks for the tip, really helped!",
            unreadCount: 0
        ),
        DMThread(
            other: users[1],
            lastMessage: "Let's catch up tomorrow.",
            unreadCount: 1
        )
    ]
    
    static let leaderboard: [User] = [
        users[0],
        users[1],
        users[2],
        users[3]
    ]
}

