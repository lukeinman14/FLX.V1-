import SwiftUI

struct ConversationListRow: View {
    var avatar: AnyView
    var title: String
    var preview: String
    var timestamp: Date
    var isUnread: Bool
    var isSent: Bool
    var onProfileTap: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Clickable profile photo
            Button(action: {
                onProfileTap?()
            }) {
                ZStack(alignment: .topTrailing) {
                    avatar
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.divider, lineWidth: 1))

                    // Pulsing green dot for unread messages
                    if isUnread {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Theme.bg, lineWidth: 2)
                            )
                            .modifier(PulsingDot())
                            .offset(x: 2, y: -2)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(title.withoutUsernamePrefix)
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
                Text(preview)
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Sent/Received timestamp (right-aligned)
            VStack(alignment: .trailing, spacing: 4) {
                Text(isSent ? "Sent" : "Received")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)

                Text(timestamp.timeAgo())
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .background(Theme.bg)
    }
}

// Pulsing dot animation for unread messages
private struct PulsingDot: ViewModifier {
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
