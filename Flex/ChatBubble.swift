import SwiftUI

struct ChatBubble: View {
    var text: String
    var isMine: Bool

    var body: some View {
        Text(text)
            .font(Theme.bodyFont())
            .foregroundStyle(Theme.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isMine ? Theme.surfaceElevated : Theme.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Theme.divider.opacity(0.35), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
    }
}
