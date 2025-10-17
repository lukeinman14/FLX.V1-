import SwiftUI

enum VoteState {
    case none
    case upvoted
    case downvoted
}

struct VoteButton: View {
    let initialScore: Int
    @State private var voteState: VoteState = .none
    @State private var upvoteCount: Int
    @State private var downvoteCount: Int

    init(score: Int) {
        self.initialScore = score
        // Assume 70% are upvotes, 30% are downvotes for initial distribution
        let upvotes = Int(Double(score) * 0.7)
        let downvotes = score - upvotes
        self._upvoteCount = State(initialValue: upvotes)
        self._downvoteCount = State(initialValue: downvotes)
    }

    var body: some View {
        HStack(spacing: 16) {
            // Upvote button with count
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    switch voteState {
                    case .none:
                        voteState = .upvoted
                        upvoteCount += 1
                    case .upvoted:
                        voteState = .none
                        upvoteCount -= 1
                    case .downvoted:
                        voteState = .upvoted
                        downvoteCount -= 1
                        upvoteCount += 1
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: voteState == .upvoted ? "arrow.up.circle.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .medium))
                    Text(formatScore(upvoteCount))
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(voteState == .upvoted ? Color(red: 0.2, green: 0.8, blue: 0.4) : Theme.textSecondary)
            }
            .buttonStyle(.plain)

            // Downvote button with count
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    switch voteState {
                    case .none:
                        voteState = .downvoted
                        downvoteCount += 1
                    case .upvoted:
                        voteState = .downvoted
                        upvoteCount -= 1
                        downvoteCount += 1
                    case .downvoted:
                        voteState = .none
                        downvoteCount -= 1
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: voteState == .downvoted ? "arrow.down.circle.fill" : "arrow.down")
                        .font(.system(size: 16, weight: .medium))
                    Text(formatScore(downvoteCount))
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundStyle(voteState == .downvoted ? Color(red: 0.9, green: 0.3, blue: 0.3) : Theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func formatScore(_ score: Int) -> String {
        if score >= 10000 {
            return String(format: "%.1fk", Double(score) / 1000.0)
        } else if score >= 1000 {
            return String(format: "%.1fk", Double(score) / 1000.0)
        } else {
            return "\(score)"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VoteButton(score: 8742)
        VoteButton(score: 856)
        VoteButton(score: 42)
    }
    .padding()
    .background(Theme.bg)
    .preferredColorScheme(.dark)
}
