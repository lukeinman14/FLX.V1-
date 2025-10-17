import SwiftUI

struct FeedRow: View {
    var avatar: Image
    var username: String
    var text: String
    var upvoteScore: String
    var comments: String
    var reposts: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(spacing: 8) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.accentMuted)
                    Text(upvoteScore)
                        .font(Theme.headingFont())
                        .foregroundStyle(Theme.accentMuted)
                }
                avatar
                    .resizable().scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 6) {
                    Text(username).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                    Text(text).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                }
            }
            HStack(spacing: 18) {
                Text("\(upvoteScore)k")
                Text("\(comments) comments")
                Text("\(reposts) reposts")
            }
            .font(Theme.smallFont())
            .foregroundStyle(Theme.textSecondary)
            Divider().background(Theme.divider)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
    }
}
