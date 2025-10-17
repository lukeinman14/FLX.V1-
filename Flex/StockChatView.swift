import SwiftUI

struct StockChatView: View {
    var symbol: String

    struct Msg: Identifiable { let id = UUID(); let text: String; let mine: Bool }
    private var messages: [Msg] {
        [
            .init(text: "What’s your target on \(symbol)?", mine: false),
            .init(text: "Watching 200D MA. Accumulating on dips.", mine: true),
            .init(text: "Earnings next week — expecting volatility.", mine: false),
            .init(text: "Agreed. I’ll trim if we gap up >5%.", mine: true)
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
                    }
                }
                .padding(.top, 8)
            }
            inputBar
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("$\(symbol) Chat")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("$\(symbol)")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message $\(symbol)", text: $draft)
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
            Button { draft.removeAll() } label: {
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
    NavigationStack { StockChatView(symbol: "AAPL") }
        .preferredColorScheme(.dark)
}
