import SwiftUI

struct ConversationView: View {
    let conversation: DMConversation

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToProfile: String?

    struct Message: Identifiable { let id = UUID(); let text: String; let mine: Bool; let timestamp: Date }

    private var messages: [Message] {
        [
            .init(text: "usdAI's gonna become the default stablecoin soon. I'm 100k deep already.", mine: false, timestamp: Date().addingTimeInterval(-86400 * 3)), // 3 days ago
            .init(text: "100k? I'm sitting on half a mil in usdAI. Check my growth this month—lapped you, bro.", mine: true, timestamp: Date().addingTimeInterval(-86400 * 2.5)), // 2.5 days ago
            .init(text: "ARENA CHALLENGE ACTIVATED\n\nu.AnonWhale vs u.ByteNomad\n\nFirst to +5% growth this week wins. Loser forfeits XP.", mine: false, timestamp: Date().addingTimeInterval(-86400 * 1.5)), // 1.5 days ago
            .init(text: "Let's see if your usdAI bet actually holds.", mine: true, timestamp: Date().addingTimeInterval(-3600)), // 1 hour ago
            .init(text: "You're gonna hand me your XP by Friday.", mine: false, timestamp: Date().addingTimeInterval(-300)) // 5 min ago
        ]
    }

    @State private var draft = ""

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header
                Divider().background(Theme.divider)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(messages.enumerated()), id: \.element.id) { index, msg in
                            // Show date separator if more than 24 hours since previous message
                            if index > 0 {
                                let previousMsg = messages[index - 1]
                                if shouldShowDateSeparator(previous: previousMsg.timestamp, current: msg.timestamp) {
                                    dateSeparator(for: msg.timestamp)
                                }
                            } else {
                                // Always show separator for first message
                                dateSeparator(for: msg.timestamp)
                            }

                            ChatBubble(text: msg.text, isMine: msg.mine)
                            timestamp(msg.timestamp, isMine: msg.mine)
                        }

                        // Add padding at bottom so messages don't go behind input bar
                        Color.clear.frame(height: 80)
                    }
                    .padding(.top, 12)
                }
            }
            .background(Theme.bg.ignoresSafeArea())

            // Floating input bar with glass effect
            inputBar
        }
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
        #if os(iOS)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
    }

    private func timestamp(_ date: Date, isMine: Bool) -> some View {
        Text(formatTimestamp(date))
            .font(Theme.smallFont())
            .foregroundStyle(Theme.textSecondary.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
            .padding(.leading, isMine ? 0 : 16)
            .padding(.trailing, isMine ? 16 : 0)
            .padding(.vertical, 8)
    }

    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeString = timeFormatter.string(from: date)

        if let days = components.day {
            if days == 0 {
                // Less than 24 hours - just show time
                return timeString
            } else if days == 1 {
                // Yesterday
                return "Yesterday \(timeString)"
            } else {
                // More than 1 day - show day name and time
                let dayFormatter = DateFormatter()
                dayFormatter.dateFormat = "EEEE h:mm a"
                return dayFormatter.string(from: date)
            }
        }

        return timeString
    }

    private func shouldShowDateSeparator(previous: Date, current: Date) -> Bool {
        let interval = current.timeIntervalSince(previous)
        return interval >= 86400 // 24 hours in seconds
    }

    private func dateSeparator(for date: Date) -> some View {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)

        var dateText: String
        if let days = components.day {
            if days == 0 {
                dateText = "Today"
            } else if days == 1 {
                dateText = "Yesterday"
            } else {
                formatter.dateFormat = "EEEE, MMMM d" // e.g., "Monday, January 15"
                dateText = formatter.string(from: date)
            }
        } else {
            formatter.dateFormat = "MMMM d, yyyy"
            dateText = formatter.string(from: date)
        }

        return Text(dateText)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Theme.surface)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
    }

    private var header: some View {
        HStack(spacing: 12) {
            // Back button - navigates back to DMs list
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentMuted)
            }

            // Clickable profile photo
            Button {
                navigateToProfile = conversation.username
            } label: {
                AvatarHelper.avatarView(for: conversation.username, size: 36)
                    .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
            }
            .buttonStyle(.plain)

            // Username without "u/" prefix
            Text(conversation.username.withoutUsernamePrefix)
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)

            Spacer()

            Button { } label: {
                Image(systemName: "phone")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentMuted)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.bg.opacity(0.6))
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            // Standalone plus button with glass effect
            Button { } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(.white.opacity(0.9))
                    .font(.system(size: 26))
            }
            .padding(8)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
            )

            // Message input bar (text field + send button)
            HStack(spacing: 12) {
                TextField("What's on your mind?", text: $draft)
                    .textFieldStyle(.plain)
                    .font(Theme.bodyFont())
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .padding(.leading, 16)

                Button { } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.system(size: 22))
                }
                .padding(.trailing, 16)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}
