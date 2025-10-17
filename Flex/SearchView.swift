import SwiftUI

struct SearchView: View {
    enum Scope: String, CaseIterable { case tickers = "Tickers", users = "Users" }
    @State private var scope: Scope = .tickers
    @State private var query: String = ""

    private let sampleTickers = ["AAPL", "NVDA", "TSLA", "BTC", "ETH", "AMD", "MSFT"]
    private let sampleUsers = ["u/AnonWhale", "u/ByteNomad", "u/SpiceTrader", "u/FremenFlow"]

    var body: some View {
        VStack(spacing: 0) {
            header
            List(results, id: \.self) { item in
                if scope == .tickers {
                    NavigationLink { StockChatView(symbol: item) } label: {
                        HStack { Text("$\(item)").font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary); Spacer() }
                    }
                    .listRowBackground(Theme.bg)
                } else {
                    NavigationLink { ProfileView(username: item, accent: Theme.accentMuted) } label: {
                        HStack { Text(item).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary); Spacer() }
                    }
                    .listRowBackground(Theme.bg)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Search")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                TextField("Search tickers or users", text: $query)
                    .textFieldStyle(.plain)
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1)))
                Menu(scope.rawValue) {
                    ForEach(Scope.allCases, id: \.self) { s in Button(s.rawValue) { scope = s } }
                }
                .font(Theme.smallFont())
                .foregroundStyle(Theme.accentMuted)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 10)
        .background(Theme.bg)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
    }

    private var results: [String] {
        let base = scope == .tickers ? sampleTickers : sampleUsers
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return base }
        return base.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}

#Preview {
    NavigationStack { SearchView() }
        .preferredColorScheme(.dark)
}
