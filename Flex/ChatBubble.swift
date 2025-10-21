import SwiftUI

struct ChatBubble: View {
    var text: String
    var isMine: Bool

    var body: some View {
        Text(text)
            .font(Theme.bodyFont())
            .foregroundStyle(isMine ? .white : .white)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isMine ? Color(red: 0.25, green: 0.60, blue: 0.30) : Color(red: 0.25, green: 0.25, blue: 0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(Theme.divider).opacity(0.35), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: isMine ? .trailing : .leading)
            .padding(.vertical, 6)
    }
}
