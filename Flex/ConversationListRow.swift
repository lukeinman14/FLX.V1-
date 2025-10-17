import SwiftUI

struct ConversationListRow: View {
    var avatar: Image
    var title: String
    var preview: String
    var score: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar
                .resizable().scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.divider, lineWidth: 1))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(score).font(Theme.smallFont()).foregroundStyle(Theme.accentMuted)
                        .padding(.horizontal, 6)
                }
                Text(preview)
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Theme.bg)
    }
}
