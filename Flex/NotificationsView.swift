import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    var icon: String
    var title: String
    var subtitle: String?
    var category: Category
    enum Category { case all, mentions, rank }
}

struct NotificationsView: View {
    @State private var selection: NotificationItem.Category = .all

    private var items: [NotificationItem] = [
        .init(icon: "swords", title: "u/MuadDib and u/HarkonnenHold just entered Arena Mode", subtitle: "Arena Challenge Activated – First to +3% growth wins.", category: .all),
        .init(icon: "diamond.fill", title: "u/FremenFlow advanced to Diamond Tier", subtitle: nil, category: .rank),
        .init(icon: "number.circle", title: "u/ByteNomad moved up 3 ranks to #7 on Leaderboard", subtitle: nil, category: .rank),
        .init(icon: "at", title: "@You You were mentioned by u/SpiceTrader", subtitle: "Rolling puts always feels risky ... respect", category: .mentions),
        .init(icon: "heart.fill", title: "u/AnonWhale liked your Thought", subtitle: "Wealth is built in the red, not the green", category: .all)
    ]

    var body: some View {
        VStack(spacing: 0) {
            segmented
            List(filtered(items)) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: item.icon)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Theme.accentMuted, Theme.textSecondary)
                        .font(.system(size: 22, weight: .semibold))
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(Theme.bodyFont())
                            .foregroundStyle(Theme.textPrimary)
                        if let sub = item.subtitle {
                            Text(sub)
                                .font(Theme.smallFont())
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .listRowBackground(Theme.bg)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
        }
        .navigationTitle("Notifications")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background(Theme.bg.ignoresSafeArea())
    }

    private var segmented: some View {
        HStack(spacing: 24) {
            seg("All", .all)
            seg("Mentions", .mentions)
            seg("Rank", .rank)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
    }

    private func seg(_ title: String, _ cat: NotificationItem.Category) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selection = cat }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(Theme.headingFont())
                    .foregroundStyle(selection == cat ? Theme.accentMuted : Theme.textSecondary)
                Rectangle()
                    .fill(selection == cat ? Theme.accentMuted : .clear)
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func filtered(_ items: [NotificationItem]) -> [NotificationItem] {
        switch selection {
        case .all: return items
        case .mentions: return items.filter { $0.category == .mentions }
        case .rank: return items.filter { $0.category == .rank }
        }
    }
}
