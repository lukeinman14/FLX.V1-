import SwiftUI
import FlexTheme

// Extension for removing u/ prefix
extension String {
    var withoutUsernamePrefix: String {
        if self.hasPrefix("u/") || self.hasPrefix("@") {
            return String(self.dropFirst(2))
        }
        return self
    }
}

// Extension for time ago formatting
extension Date {
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(self)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 {
            return "Just now"
        } else if minutes < 60 {
            return "\(minutes)m"
        } else if hours < 24 {
            return "\(hours)h"
        } else {
            return "\(days)d"
        }
    }
}

// Avatar helper to generate CryptoPunk avatars
struct AvatarHelper {
    static func avatarView(for username: String, size: CGFloat = 40) -> some View {
        let imageName = getPunkImageName(for: username)
        return Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    private static func getPunkImageName(for username: String) -> String {
        let imageMap: [String: String] = [
            "u/You": "punk-you",
            "u/CryptoWhale": "punk-cryptowhale",
            "u/ByteWhale": "punk-bytewhale",
            "u/QuantJunkie": "punk-quantjunkie",
            "u/AnonFin": "punk-anonfin"
        ]
        return imageMap[username] ?? "punk-you"
    }
}

// ProfileView placeholder (should import from main app)
struct ProfileView: View {
    let username: String

    var body: some View {
        Text("Profile: \(username)")
            .navigationTitle(username)
    }
}

struct Thread: Identifiable, Hashable {
    let id = UUID()
    let avatar: String
    let handle: String
    let lastMessage: String
    let unreadCount: Int
    let messages: [Message]
    let lastMessageTimestamp: Date
    let lastMessageWasSent: Bool // true if sent by current user, false if received
    let isUnread: Bool // true if there are unread messages

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Thread, rhs: Thread) -> Bool {
        lhs.id == rhs.id
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSpecial: Bool
    let isCurrentUser: Bool
    let timestamp: Date = Date()
}

struct MockData {
    static let threads = [
        Thread(
            avatar: "person.circle.fill",
            handle: "u/CryptoWhale",
            lastMessage: "Did you see that $BTC pump?",
            unreadCount: 2,
            messages: [
                Message(text: "Hey, how are you?", isSpecial: false, isCurrentUser: false),
                Message(text: "I'm good, thanks!", isSpecial: true, isCurrentUser: true),
                Message(text: "Did you see that $BTC pump?", isSpecial: false, isCurrentUser: false)
            ],
            lastMessageTimestamp: Date().addingTimeInterval(-300), // 5 min ago
            lastMessageWasSent: false,
            isUnread: true
        ),
        Thread(
            avatar: "person.circle.fill",
            handle: "u/ByteWhale",
            lastMessage: "Thanks for the tip!",
            unreadCount: 0,
            messages: [
                Message(text: "Check out $NVDA", isSpecial: false, isCurrentUser: true),
                Message(text: "Thanks for the tip!", isSpecial: false, isCurrentUser: false)
            ],
            lastMessageTimestamp: Date().addingTimeInterval(-3600), // 1 hour ago
            lastMessageWasSent: false,
            isUnread: false
        ),
        Thread(
            avatar: "person.circle.fill",
            handle: "u/QuantJunkie",
            lastMessage: "See you tomorrow",
            unreadCount: 0,
            messages: [
                Message(text: "Let's meet tomorrow.", isSpecial: false, isCurrentUser: false),
                Message(text: "Sure thing.", isSpecial: false, isCurrentUser: true),
                Message(text: "See you tomorrow", isSpecial: false, isCurrentUser: true)
            ],
            lastMessageTimestamp: Date().addingTimeInterval(-7200), // 2 hours ago
            lastMessageWasSent: true,
            isUnread: false
        ),
        Thread(
            avatar: "person.circle.fill",
            handle: "u/AnonFin",
            lastMessage: "What's your $AAPL play?",
            unreadCount: 1,
            messages: [
                Message(text: "What's your $AAPL play?", isSpecial: false, isCurrentUser: false)
            ],
            lastMessageTimestamp: Date().addingTimeInterval(-120), // 2 min ago
            lastMessageWasSent: false,
            isUnread: true
        )
    ]
}

struct DMsView: View {
    @State private var searchText = ""
    @State private var navigateToProfile: String?

    var filteredThreads: [Thread] {
        if searchText.isEmpty {
            return MockData.threads
        } else {
            return MockData.threads.filter {
                $0.handle.localizedCaseInsensitiveContains(searchText) ||
                $0.lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Messages")
                    .font(.largeTitle.bold())
                    .padding(.top, 44)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .foregroundColor(FlexTheme.accent)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(FlexTheme.accent.opacity(0.6))
                    TextField("Search", text: $searchText)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.none)
                        .foregroundColor(FlexTheme.accent)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(FlexTheme.card)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                List {
                    ForEach(filteredThreads) { thread in
                        NavigationLink(value: thread) {
                            HStack(spacing: 12) {
                                // Clickable profile photo
                                Button(action: {
                                    navigateToProfile = thread.handle
                                }) {
                                    ZStack(alignment: .topTrailing) {
                                        AvatarHelper.avatarView(for: thread.handle, size: 44)

                                        // Pulsing green dot for unread messages
                                        if thread.isUnread {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 12, height: 12)
                                                .overlay(
                                                    Circle()
                                                        .stroke(FlexTheme.background, lineWidth: 2)
                                                )
                                                .modifier(PulsingDot())
                                                .offset(x: 2, y: -2)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(thread.handle.withoutUsernamePrefix)
                                        .fontWeight(.semibold)
                                        .foregroundColor(FlexTheme.accent)
                                    Text(thread.lastMessage)
                                        .font(.subheadline)
                                        .foregroundColor(FlexTheme.accent.opacity(0.7))
                                        .lineLimit(1)
                                }

                                Spacer()

                                // Sent/Received timestamp (right-aligned)
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(thread.lastMessageWasSent ? "Sent" : "Received")
                                        .font(.caption2)
                                        .foregroundColor(FlexTheme.accent.opacity(0.6))

                                    Text(thread.lastMessageTimestamp.timeAgo())
                                        .font(.caption2)
                                        .foregroundColor(Color(red: 0.1, green: 1.0, blue: 0.4)) // Neon green
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(FlexTheme.background)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(FlexTheme.background)
            }
            .background(FlexTheme.background.ignoresSafeArea())
            .navigationDestination(for: Thread.self) { thread in
                ChatView(thread: thread)
            }
            .navigationDestination(item: $navigateToProfile) { username in
                ProfileView(username: username)
            }
        }
    }
}

// Pulsing dot animation for unread messages
struct PulsingDot: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct ChatView: View {
    let thread: Thread
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(thread.messages) { message in
                            HStack {
                                if message.isCurrentUser {
                                    Spacer()
                                }
                                
                                Text(message.text)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(FlexTheme.card)
                                            .overlay(
                                                message.isSpecial ?
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(FlexTheme.neonStroke, lineWidth: 2)
                                                : nil
                                            )
                                    )
                                    .foregroundColor(FlexTheme.accent)
                                
                                if !message.isCurrentUser {
                                    Spacer()
                                }
                            }
                            .padding(message.isCurrentUser ? .leading : .trailing, 80)
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(FlexTheme.background)
            }
        }
        .navigationTitle(thread.handle)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlexTheme.background.ignoresSafeArea())
    }
}

struct DMsView_Previews: PreviewProvider {
    static var previews: some View {
        FlexThemePreview {
            DMsView()
        }
    }
}
