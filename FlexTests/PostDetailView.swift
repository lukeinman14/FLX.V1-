import SwiftUI

struct FlexPostModel: Hashable {
    let author: Author
    let text: String
    let comments: [FlexCommentModel]
}

struct FlexCommentModel: Hashable {
    let author: Author
    let text: String
}

struct FlexPostDetailView: View {
    let post: FlexPostModel
    @State private var newCommentText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Post header
                    HStack(spacing: 12) {
                        Image(post.author.avatar)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        Text(post.author.handle)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    
                    // Post text card
                    Text(post.text)
                        .font(.body)
                        .padding()
                        .background(FlexTheme.card)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(FlexTheme.neonStroke, lineWidth: 2)
                        )
                    
                    // Comments list
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(post.comments, id: \.self) { comment in
                            CommentRow(comment: comment)
                        }
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
            
            Divider()
            
            // Input bar
            HStack {
                TextField("Add a comment", text: $newCommentText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: {
                    // No real action needed
                    newCommentText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(newCommentText.isEmpty ? .gray : .accentColor)
                }
                .disabled(newCommentText.isEmpty)
            }
            .padding()
            .background(FlexTheme.card)
        }
    }
}

struct CommentRow: View {
    let comment: FlexCommentModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(comment.author.avatar)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.author.handle)
                    .font(.subheadline)
                    .bold()
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}
