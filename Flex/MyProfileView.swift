import SwiftUI

struct MyProfileView: View {
    @Environment(PlayerState.self) private var player
    private let model = GamificationModel.demo

    @State private var timeframe: ProfileView.Timeframe = .weekly

    var body: some View {
        let user = player.profile
        let currentTier = model.currentTier(for: user)
        let progressInfo = model.nextTierProgress(for: user)

        ScrollView {
            VStack(spacing: 16) {
                header(username: user.username, tier: currentTier)
                xpAndStreak
                netWorthCard(user: user, tier: currentTier)
                progressCard(currentTier: currentTier, progress: progressInfo.progress, next: progressInfo.next)
                quickActions
                placeholderHoldings
                placeholderPosts
            }
            .padding(.bottom, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("My Profile")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func header(username: String, tier: Tier?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill").font(.system(size: 42)).foregroundStyle(Theme.accentMuted)
            VStack(alignment: .leading, spacing: 4) {
                Text(username).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                if let tier {
                    Text("\(tier.name.uppercased()) TIER")
                        .font(Theme.smallFont())
                        .foregroundStyle(tier.color)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var xpAndStreak: some View {
        HStack(spacing: 12) {
            XPBadge(xp: player.xp)
            StreakBadge(streak: player.dailyStreak)
            Spacer()
            Button("Check-in") { player.checkInToday() }
                .font(Theme.smallFont())
                .foregroundStyle(Theme.accentMuted)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }

    private func netWorthCard(user: UserProfile, tier: Tier?) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Net Worth").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text("$\(Int(user.netWorthUSD).formatted())")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text("Tier").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text(tier?.name.uppercased() ?? "UNRANKED")
                    .font(Theme.headingFont())
                    .foregroundStyle(tier?.color ?? Theme.accentMuted)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }

    private func progressCard(currentTier: Tier?, progress: Double, next: Tier?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Progress to \(next?.name ?? "Next Tier")")
                    .font(Theme.headingFont()).foregroundStyle(Theme.accentMuted)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(Theme.smallFont()).foregroundStyle(Theme.accentMuted)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Theme.accentMuted, Theme.accent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: Swift.max(8, geo.size.width * progress))
                }
            }
            .frame(height: 14)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surfaceElevated))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink { ArenaListView() } label: {
                Label("Arena", systemImage: "swords")
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1))
            }
            NavigationLink { NotificationsView() } label: {
                Label("Notifications", systemImage: "bell")
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private var placeholderHoldings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Holdings").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary).padding(.horizontal, 16)
            ForEach([Holding(symbol: "AAPL", amount: "120 sh", value: "$22k"), Holding(symbol: "BTC", amount: "0.8", value: "$52k")]) { h in
                NavigationLink { StockChatView(symbol: h.symbol) } label: {
                    HStack {
                        Text(h.symbol).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                        Spacer()
                        Text(h.amount).font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                        Text(h.value).font(Theme.bodyFont()).foregroundStyle(Theme.accentMuted)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Theme.surface)
                    .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
                }
            }
        }
        .background(Theme.bg)
    }

    private var placeholderPosts: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Posts").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary).padding(.horizontal, 16)
            ForEach(["Stacking weekly DCA.", "Closed covered calls for 1.8%.", "Rebalancing 70/30."] , id: \.self) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text(post).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 18) {
                        Text("1.2k")
                        Text("214 comments")
                        Text("87 reposts")
                    }
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.textSecondary)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
                .padding(.horizontal, 16)
            }
        }
        .padding(.bottom, 20)
        .background(Theme.bg)
    }
}

#Preview {
    @Previewable @State var player = PlayerState(profile: UserProfile(username: "u/You", netWorthUSD: 8200))
    return NavigationStack { MyProfileView().environment(player) }
        .preferredColorScheme(.dark)
}
