import SwiftUI

struct LeaderboardRow: View {
    var avatar: AnyView
    var name: String
    var amount: String
    var body: some View {
        HStack(spacing: 14) {
            avatar
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
            Text(name).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(amount).font(Theme.bodyFont()).foregroundStyle(Theme.accentMuted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}

struct TierHeader: View {
    let tier: Tier
    let locked: Bool
    var body: some View {
        HStack {
            Text(tier.name.uppercased())
                .font(Theme.smallFont().weight(.semibold))
                .foregroundStyle(tier.color)
            Spacer()
            Text(tier.rangeDescription)
                .font(Theme.smallFont())
                .foregroundStyle(tier.color.opacity(0.8))
            if locked {
                Image(systemName: "lock.fill").foregroundStyle(tier.color.opacity(0.8))
            }
        }
        .padding(.vertical, 4)
    }
}

struct ProgressCard: View {
    let title: String
    let subtitle: String
    let progress: Double // 0..1

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(Theme.headingFont()).foregroundStyle(Theme.accentMuted)
            Text(subtitle).font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
            // Numeric anchors and current %
            HStack {
                Text("0%")
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.accentMuted)
                Spacer()
                Text("100%")
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.textSecondary)
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
        .padding(.top, 8)
    }
}

struct LeaderboardView: View {
    @Environment(\.shimTabSelection) private var shimTabSelection
    @Environment(PlayerState.self) private var player

    private let model = GamificationModel.demo
    private let userDataManager = UserDataManager.shared
    @State private var isLoading = true

    var body: some View {
        let current = model.currentTier(for: player.profile)
        let progressInfo = model.nextTierProgress(for: player.profile)

        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                header
                if isLoading {
                    loadingPlaceholder
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                } else {
                    listContent(current: current, progressInfo: progressInfo)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Leaderboard")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .onAppear {
            if isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) { isLoading = false }
                }
            }
        }
    }

    private func listContent(current: Tier?, progressInfo: (next: Tier?, progress: Double)) -> some View {
        List {
            Section {
                ProgressCard(
                    title: current?.name.uppercased() ?? "UNRANKED",
                    subtitle: progressSubtitle(current: current, next: progressInfo.next),
                    progress: progressInfo.progress
                )
                .listRowBackground(Theme.bg)
            }

            ForEach(model.tiers) { tier in
                let locked = !(tier.contains(player.profile.netWorthUSD)) && (tier.minNetWorth > player.profile.netWorthUSD)
                let usersInTier = userDataManager.getUsersInTier(tier)
                Section(header: TierHeader(tier: tier, locked: locked)) {
                    if locked {
                        HStack {
                            Rectangle().fill(tier.color.opacity(0.5)).frame(width: 4).cornerRadius(2)
                            Image(systemName: "lock.fill").foregroundStyle(Theme.textSecondary)
                            Text("Locked. Reach \(tier.rangeDescription) to unlock.")
                                .font(Theme.bodyFont())
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .listRowBackground(Theme.bg)
                    } else {
                        ForEach(Array(usersInTier.enumerated()), id: \.element.username) { index, userProfile in
                            NavigationLink {
                                ProfileView(username: userProfile.username, accent: tier.color)
                            } label: {
                                colorCodedRow(
                                    username: userProfile.username,
                                    name: userProfile.username.withoutUsernamePrefix,
                                    amount: userDataManager.formatNetWorth(userProfile.netWorthUSD) + (index == 0 ? " ▲" : ""),
                                    color: tier.color
                                )
                            }
                        }
                    }
                }
            }

            Text("Season ends in: 23d 12h 45m")
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
                .listRowBackground(Theme.bg)
        }
#if os(iOS)
        .listStyle(.insetGrouped)
#else
        .listStyle(.sidebar)
#endif
        .scrollContentBackground(.hidden)
        .tint(Theme.accentMuted)
        .environment(\.defaultMinListRowHeight, 64)
    }

    private var loadingPlaceholder: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)).frame(height: 100).padding(.horizontal, 16)
            ForEach(0..<3) { _ in
                RoundedRectangle(cornerRadius: 12).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1)).frame(height: 64).padding(.horizontal, 16)
            }
            Spacer(minLength: 0)
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }

    private func colorCodedRow(username: String, name: String, amount: String, color: Color) -> some View {
        LeaderboardRow(avatar: AnyView(AvatarHelper.avatarView(for: username, size: 44)), name: name, amount: amount)
            .listRowBackground(Theme.bg)
            .overlay(alignment: .leading) { Rectangle().fill(color.opacity(0.6)).frame(width: 4) }
            .tint(color)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("Leaderboard")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.bg)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: Alignment.bottom)
    }

    private func progressSubtitle(current: Tier?, next: Tier?) -> String {
        if let current, let next { return "Progress to \(next.name) tier" }
        if current != nil { return "Top tier achieved" }
        return "Get ranked by growing your net worth"
    }
}

private struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(gradient: Gradient(colors: [Color.clear, Theme.accent.opacity(0.2), Color.clear]), startPoint: .leading, endPoint: .trailing)
                    .rotationEffect(.degrees(10))
                    .offset(x: phase)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 240
                }
            }
    }
}

private extension View {
    func shimmering() -> some View { self.modifier(Shimmer()) }
}
