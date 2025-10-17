import SwiftUI

struct LeaderboardRow: View {
    var avatar: Image
    var name: String
    var amount: String
    var body: some View {
        HStack(spacing: 14) {
            avatar.resizable().scaledToFill()
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
                .foregroundStyle(Theme.textSecondary)
            if locked {
                Image(systemName: "lock.fill").foregroundStyle(Theme.textSecondary)
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
    @Environment(\.tabSelection) private var tabSelection

    private let model = GamificationModel.demo
    private let user = UserProfile(username: "u/You", netWorthUSD: 8_200)
    @State private var isLoading = true

    var body: some View {
        let current = model.currentTier(for: user)
        let progressInfo = model.nextTierProgress(for: user)

        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                header
                if isLoading {
                    loadingPlaceholder
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    listContent(current: current, progressInfo: progressInfo)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            backFloatingButton
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { tabSelection?.wrappedValue = 0 }) {
                    Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundStyle(Theme.accentMuted)
                }
            }
        }
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
                let locked = !(tier.contains(user.netWorthUSD)) && (tier.minNetWorth > user.netWorthUSD)
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
                        NavigationLink { ProfileView(username: "u AnonFin", accent: tier.color) } label: { colorCodedRow(name: "u AnonFin", amount: "$10 M ▲", color: tier.color) }
                        NavigationLink { ProfileView(username: "u ByteWhale", accent: tier.color) } label: { colorCodedRow(name: "u ByteWhale", amount: "8,45 M", color: tier.color) }
                        NavigationLink { ProfileView(username: "u MuadDib", accent: tier.color) } label: { colorCodedRow(name: "u MuadDib", amount: "6,12 M", color: tier.color) }
                    }
                }
            }

            Text("Season ends in: 23d 12h 45m")
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 24, trailing: 16))
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
                .listRowBackground(Theme.bg)
        }
        .listStyle(.insetGrouped)
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

    private var backFloatingButton: some View {
        Button(action: { tabSelection?.wrappedValue = 0 }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.bg)
                .padding(10)
                .background(Circle().fill(Theme.accentMuted))
        }
        .padding(.leading, 12)
        .padding(.top, 8)
    }

    private func colorCodedRow(name: String, amount: String, color: Color) -> some View {
        LeaderboardRow(avatar: Image(systemName: "person.crop.circle"), name: name, amount: amount)
            .listRowBackground(Theme.bg)
            .overlay(alignment: .leading) { Rectangle().fill(color.opacity(0.6)).frame(width: 4) }
            .tint(color)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: { tabSelection?.wrappedValue = 0 }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Theme.accentMuted)
            }
            Text("Leaderboard")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.bg)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
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
                LinearGradient(gradient: Gradient(colors: [.clear, Theme.accent.opacity(0.2), .clear]), startPoint: .leading, endPoint: .trailing)
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
