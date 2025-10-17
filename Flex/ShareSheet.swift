import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ShareSheet: View {
    let postURL: String
    let postText: String
    @Environment(\.dismiss) private var dismiss
    @State private var showSendToUser = false
    @State private var copiedToClipboard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("Share Post")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)

                    Text(postText.prefix(100) + (postText.count > 100 ? "..." : ""))
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)

                Divider().background(Theme.divider)

                // Share options
                VStack(spacing: 0) {
                    // Send via iMessage
                    ShareOptionButton(
                        icon: "message.fill",
                        title: "Share via iMessage",
                        iconColor: .green
                    ) {
                        shareViaMessages()
                    }

                    Divider().background(Theme.divider).padding(.leading, 60)

                    // Copy Link
                    ShareOptionButton(
                        icon: copiedToClipboard ? "checkmark.circle.fill" : "doc.on.doc.fill",
                        title: copiedToClipboard ? "Link Copied!" : "Copy Link",
                        iconColor: copiedToClipboard ? .green : Theme.accentMuted
                    ) {
                        copyLink()
                    }

                    Divider().background(Theme.divider).padding(.leading, 60)

                    // Send to User
                    ShareOptionButton(
                        icon: "person.crop.circle.fill.badge.checkmark",
                        title: "Send to User",
                        iconColor: Theme.accentMuted
                    ) {
                        showSendToUser = true
                    }
                }
                .padding(.vertical, 8)

                Spacer()

                // Cancel button
                Button(action: { dismiss() }) {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.surface)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Theme.bg)
            .navigationBarHidden(true)
            .sheet(isPresented: $showSendToUser) {
                SendToUserSheet(postURL: postURL, postText: postText)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func shareViaMessages() {
        #if os(iOS)
        let message = "Check out this post: \(postURL)"
        if let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "sms:&body=\(encodedMessage)") {
            UIApplication.shared.open(url)
        }
        #endif
        dismiss()
    }

    private func copyLink() {
        #if os(iOS)
        UIPasteboard.general.string = postURL
        #endif
        withAnimation {
            copiedToClipboard = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

struct ShareOptionButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(iconColor)
                    .frame(width: 32)

                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(Theme.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }
}

struct SendToUserSheet: View {
    let postURL: String
    let postText: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedUser: String?

    // Mock users - in production this would come from following/friends list
    private let availableUsers = [
        "u/CryptoWhale",
        "u/ByteWhale",
        "u/QuantJunkie",
        "u/AlgoKing",
        "u/ValueInvestor",
        "u/DeFiNinja"
    ]

    private var filteredUsers: [String] {
        if searchText.isEmpty {
            return availableUsers
        }
        return availableUsers.filter { $0.lowercased().contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Theme.textSecondary)

                    TextField("Search users...", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Theme.textPrimary)
                }
                .padding(12)
                .background(Theme.surface)
                .cornerRadius(10)
                .padding()

                // User list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredUsers, id: \.self) { user in
                            Button(action: {
                                selectedUser = user
                                sendToUser(user)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.crop.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.purple, .blue, .cyan],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )

                                    Text(user.withoutUsernamePrefix)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundStyle(Theme.textPrimary)

                                    Spacer()

                                    if selectedUser == user {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            if user != filteredUsers.last {
                                Divider().background(Theme.divider).padding(.leading, 72)
                            }
                        }
                    }
                }
            }
            .background(Theme.bg)
            .navigationTitle("Send to User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentMuted)
                }
            }
        }
    }

    private func sendToUser(_ user: String) {
        // In production, this would send a DM with the post link
        // For now, we'll just show it was sent and dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#Preview {
    ShareSheet(
        postURL: "https://flex.app/post/12345",
        postText: "$BTC breaking new highs! Institutional money is flooding in. ETF inflows are absolutely massive."
    )
    .preferredColorScheme(.dark)
}
