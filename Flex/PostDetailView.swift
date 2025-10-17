import SwiftUI

struct Post: Identifiable { let id = UUID(); var author: String; var text: String }
struct Comment: Identifiable { let id = UUID(); var author: String; var text: String }

struct PostDetailView: View {
    var post: Post
    @State private var comments: [Comment] = [
        Comment(author: "u/AnonWhale", text: "Agree — buying the dip."),
        Comment(author: "u/SpiceTrader", text: "Rolling weeklies for premium."),
        Comment(author: "u/ByteNomad", text: "Careful, CPI tomorrow.")
    ]
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(post.author).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                        Text(post.text).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                    }
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

                    Divider().background(Theme.divider)

                    ForEach(comments) { c in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(c.author).font(Theme.smallFont()).foregroundStyle(Theme.accentMuted)
                            Text(c.text).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Theme.surface)
                        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            inputBar
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Post")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Add a comment", text: $draft)
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
            Button {
                if !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    comments.append(Comment(author: "u/You", text: draft))
                    draft.removeAll()
                }
            } label: {
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

#Preview {
    NavigationStack { PostDetailView(post: Post(author: "u/AnonWhale", text: "Every dip feels scary, but wealth is built in the red, not the green.")) }
        .preferredColorScheme(.dark)
}
