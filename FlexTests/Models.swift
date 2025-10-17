import Foundation

struct User: Identifiable {
    let id: UUID
    var handle: String
    var avatar: String
    var score: Double
}

struct Comment: Identifiable {
    let id: UUID
    var author: User
    var text: String
}

struct Post: Identifiable {
    let id: UUID
    var author: User
    var text: String
    var upvotes: Int
    var comments: [Comment]
    var reposts: Int
}

struct DMThread: Identifiable {
    let id: UUID
    var other: User
    var lastMessage: String
    var unreadCount: Int
}

enum MockData {
    static let users: [User] = [
        User(id: UUID(), handle: "u/AnonFin", avatar: "person.circle.fill", score: 2543.2),
        User(id: UUID(), handle: "u/ByteWhale", avatar: "person.circle.fill", score: 1987.5),
        User(id: UUID(), handle: "u/CryptoSage", avatar: "person.circle.fill", score: 1804.7),
        User(id: UUID(), handle: "u/HashHound", avatar: "person.circle.fill", score: 1650.9)
    ]
    
    static let posts: [Post] = [
        Post(
            id: UUID(),
            author: users[0],
            text: "Just discovered an amazing new DeFi project, check it out!",
            upvotes: 134,
            comments: [
                Comment(id: UUID(), author: users[1], text: "Looks promising!"),
                Comment(id: UUID(), author: users[2], text: "I'm in!")
            ],
            reposts: 23
        ),
        Post(
            id: UUID(),
            author: users[1],
            text: "Bitcoin is still the king of crypto.",
            upvotes: 98,
            comments: [
                Comment(id: UUID(), author: users[0], text: "Absolutely agree."),
                Comment(id: UUID(), author: users[3], text: "Long live BTC!")
            ],
            reposts: 17
        ),
        Post(
            id: UUID(),
            author: users[2],
            text: "Anyone tried the new staking platform?",
            upvotes: 76,
            comments: [
                Comment(id: UUID(), author: users[3], text: "Yes, it’s great!")
            ],
            reposts: 9
        )
    ]
    
    static let threads: [DMThread] = [
        DMThread(
            id: UUID(),
            other: users[3],
            lastMessage: "Did you check the latest token launch?",
            unreadCount: 2
        ),
        DMThread(
            id: UUID(),
            other: users[2],
            lastMessage: "Thanks for the tip, really helped!",
            unreadCount: 0
        ),
        DMThread(
            id: UUID(),
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
