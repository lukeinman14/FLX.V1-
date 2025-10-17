import SwiftUI

struct ConversationView: View {
    let conversation: DMConversation

    @Environment(\.dismiss) private var dismiss
    @State private var navigateToProfile: String?

    struct Message: Identifiable { let id = UUID(); let text: String; let mine: Bool }

    private var messages: [Message] {
        [
            .init(text: "usdAI's gonna become the default stablecoin soon. I'm 100k deep already.", mine: false),
            .init(text: "100k? I'm sitting on half a mil in usdAI. Check my growth this month—lapped you, bro.", mine: true),
            .init(text: "ARENA CHALLENGE ACTIVATED\n\nu.AnonWhale vs u.ByteNomad\n\nFirst to +5% growth this week wins. Loser forfeits XP.", mine: false),
            .init(text: "Let's see if your usdAI bet actually holds.", mine: true),
            .init(text: "You're gonna hand me your XP by Friday.", mine: false)
        ]
    }

    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(Theme.divider)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(messages) { msg in
                        ChatBubble(text: msg.text, isMine: msg.mine)
                        timestamp("4:07 PM")
                    }
                }
                .padding(.top, 12)
            }
            inputBar
        }
        .background(Theme.bg.ignoresSafeArea())
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarVisibility(.visible, for: .tabBar)
        #endif
        .navigationDestination(item: $navigateToProfile) { username in
            ProfileView(username: username)
        }
    }

    private func timestamp(_ t: String) -> some View {
        Text(t)
            .font(Theme.smallFont())
            .foregroundStyle(Theme.textSecondary.opacity(0.9))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 22)
            .padding(.vertical, 8)
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
            Button { } label: {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Theme.accentMuted)
                    .font(.system(size: 26))
            }
            TextField("Start a message", text: $draft)
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
            Button { } label: {
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
