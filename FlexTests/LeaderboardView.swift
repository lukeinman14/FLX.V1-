import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        List {
            Section(header: Text("Diamond Tier").foregroundColor(FlexTheme.secondary)) {
                ForEach(MockData.leaderboard.filter { $0.tier == .diamond }.sorted { $0.score > $1.score }) { user in
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                        Text(user.handle)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                            Text(formattedBalance(user.balance))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Section(header: Text("Gold Tier").foregroundColor(FlexTheme.secondary)) {
                ForEach(MockData.leaderboard.filter { $0.tier == .gold }.sorted { $0.score > $1.score }) { user in
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                        Text(user.handle)
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                            Text(formattedBalance(user.balance))
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            Section(footer: Text("Season ends in: 23d 12h 45m").foregroundColor(FlexTheme.secondary)) {
                EmptyView()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func formattedBalance(_ balance: Double) -> String {
        if balance >= 1_000_000 {
            return String(format: "$%.0f M", balance / 1_000_000)
        } else if balance >= 1_000 {
            return String(format: "$%.0f K", balance / 1_000)
        } else {
            return String(format: "$%.0f", balance)
        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LeaderboardView()
        }
    }
}

// Assuming these for preview/testing (not part of requested code but help for context):

enum Tier {
    case diamond, gold, silver
}

struct User: Identifiable {
    let id = UUID()
    let handle: String
    let balance: Double
    let score: Int
    let tier: Tier
}

struct MockData {
    static let leaderboard: [User] = [
        User(handle: "@diamond1", balance: 10_000_000, score: 100, tier: .diamond),
        User(handle: "@diamond2", balance: 8_500_000, score: 90, tier: .diamond),
        User(handle: "@gold1", balance: 4_500_000, score: 80, tier: .gold),
        User(handle: "@gold2", balance: 3_200_000, score: 70, tier: .gold),
    ]
}

struct FlexTheme {
    static let secondary = Color.gray
}
