import SwiftUI

struct LeaderboardRow: View {
    var avatar: AnyView
    var name: String
    var amount: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 14) {
            avatar
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
            Text(name)
                .font(Theme.bodyFont().weight(.medium))
                .foregroundStyle(colorScheme == .dark ? Theme.textPrimary : .white)
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.15), radius: 2, x: 0, y: 1)
            Spacer()
            Text(amount)
                .font(Theme.bodyFont())
                .foregroundStyle(colorScheme == .dark ? Theme.accentMuted : Color.white.opacity(0.85))
                .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.15), radius: 2, x: 0, y: 1)
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
    let tierColor: Color?
    @Environment(\.colorScheme) private var colorScheme
    @State private var pulseOpacity: Double = 1.0
    @State private var beaconScale: CGFloat = 1.0
    @State private var beaconOpacity: Double = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 3D Metallic tier name
            if let color = tierColor {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                color.opacity(0.8),
                                color,
                                color.opacity(0.6),
                                color
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.5), radius: 2, x: 0, y: 1)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .overlay(
                        Text(title)
                            .font(Theme.headingFont().weight(.bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.6),
                                        .clear,
                                        .clear,
                                        .clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                            .blendMode(.overlay)
                    )
            } else {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(colorScheme == .dark ? Theme.accentMuted : .white)
            }
            Text(subtitle).font(.system(size: 15, weight: .medium)).foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.85))
            // Numeric anchors and current %
            HStack {
                Text("0%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.7))
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(colorScheme == .dark ? Theme.accentMuted : .white)
                Spacer()
                Text("100%")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.7))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.15),
                                    Color.white.opacity(colorScheme == .dark ? 0.03 : 0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(
                                    Color.white.opacity(colorScheme == .dark ? 0.1 : 0.25),
                                    lineWidth: 1
                                )
                        )

                    // Progress fill with pulsing green effect and beacon
                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.8, blue: 0.4),
                                        Color(red: 0.15, green: 0.7, blue: 0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        Color(red: 0.25, green: 0.85, blue: 0.45).opacity(0.6),
                                        lineWidth: 1
                                    )
                            )
                            .opacity(pulseOpacity)

                        // Beacon at the end
                        if progress > 0.05 {
                            ZStack {
                                // Outer glow
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.9, blue: 0.5).opacity(beaconOpacity * 0.8),
                                                Color(red: 0.3, green: 0.9, blue: 0.5).opacity(0)
                                            ],
                                            center: .center,
                                            startRadius: 0,
                                            endRadius: 8
                                        )
                                    )
                                    .frame(width: 16, height: 16)
                                    .scaleEffect(beaconScale)

                                // Inner bright core
                                Circle()
                                    .fill(colorScheme == .dark ? Color(red: 0.3, green: 0.9, blue: 0.5) : Color.white)
                                    .frame(width: 6, height: 6)
                                    .opacity(beaconOpacity)
                            }
                            .offset(x: -3)
                        }
                    }
                    .frame(width: Swift.max(8, geo.size.width * progress))
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true)
                        ) {
                            pulseOpacity = 0.6
                        }

                        withAnimation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                        ) {
                            beaconScale = 1.4
                            beaconOpacity = 0.5
                        }
                    }
                }
            }
            .frame(height: 20)
        }
        .padding(20)
        .background(
            Group {
                if colorScheme == .dark {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.5))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.1),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    ),
                                    lineWidth: 0.5
                                )
                                .blur(radius: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.72, green: 0.72, blue: 0.74, opacity: 0.85),
                                    Color(red: 0.67, green: 0.67, blue: 0.69, opacity: 0.90),
                                    Color(red: 0.64, green: 0.64, blue: 0.66, opacity: 0.95)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.4))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.7),
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.4),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    ),
                                    lineWidth: 1
                                )
                                .blur(radius: 1)
                        )
                        .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        .shadow(color: Color.white.opacity(0.4), radius: 1, x: 0, y: -1)
                }
            }
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

struct LeaderboardView: View {
    @Environment(\.shimTabSelection) private var shimTabSelection
    @Environment(PlayerState.self) private var player
    @Environment(\.colorScheme) private var colorScheme

    private let model = GamificationModel.demo
    private let userDataManager = UserDataManager.shared
    @State private var isLoading = true

    var body: some View {
        let current = model.currentTier(for: player.profile)
        let progressInfo = model.nextTierProgress(for: player.profile)

        NavigationStack {
            ZStack {
                if isLoading {
                    loadingPlaceholder
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
                } else {
                    listContent(current: current, progressInfo: progressInfo)
                        .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .overlay(alignment: .top) {
                // Full-screen gradient blur from top of screen down
                VStack(spacing: 0) {
                    // Graduated blur layers - stronger at top, weaker at bottom
                    ZStack {
                        // Layer 1: Strong blur at top (most intense)
                        LinearGradient(
                            colors: [
                                Theme.bg,
                                Theme.bg,
                                Theme.bg.opacity(0.95),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blur(radius: 50)
                        .frame(height: 80)
                        .offset(y: 0)

                        // Layer 2: Medium blur in middle
                        LinearGradient(
                            colors: [
                                Theme.bg.opacity(0.85),
                                Theme.bg.opacity(0.70),
                                Theme.bg.opacity(0.45),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blur(radius: 25)
                        .frame(height: 120)
                        .offset(y: 20)

                        // Layer 3: Light blur near bottom
                        LinearGradient(
                            colors: [
                                Theme.bg.opacity(0.35),
                                Theme.bg.opacity(0.20),
                                Theme.bg.opacity(0.08),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .blur(radius: 8)
                        .frame(height: 160)
                        .offset(y: 0)
                    }
                    .frame(height: 160)

                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 0) {
                    // Title header
                    HStack {
                        Spacer()
                        Text("Leaderboard")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        Spacer()
                    }
                    .frame(height: 52)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Leaderboard")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            #endif
        }
        .background((colorScheme == .dark ? Theme.bg : Color.white).ignoresSafeArea())
        .onAppear {
            if isLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.easeOut(duration: 0.35)) { isLoading = false }
                }
            }
        }
    }

    @ViewBuilder
    private func glassMorphBackground() -> some View {
        if colorScheme == .dark {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.72, blue: 0.74, opacity: 0.85),
                            Color(red: 0.67, green: 0.67, blue: 0.69, opacity: 0.90),
                            Color(red: 0.64, green: 0.64, blue: 0.66, opacity: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .shadow(color: Color.white.opacity(0.4), radius: 1, x: 0, y: -1)
        }
    }

    private func listContent(current: Tier?, progressInfo: (next: Tier?, progress: Double)) -> some View {
        List {
            Section {
                ProgressCard(
                    title: current?.name.uppercased() ?? "UNRANKED",
                    subtitle: progressSubtitle(current: current, next: progressInfo.next),
                    progress: progressInfo.progress,
                    tierColor: current?.color
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
                .listRowSeparator(.hidden)
            }

            Section {
                FlipClockView(endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date())
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
            }

            ForEach(model.tiers.reversed()) { tier in
                let locked = !(tier.contains(player.profile.netWorthUSD)) && (tier.minNetWorth > player.profile.netWorthUSD)
                let usersInTier = userDataManager.getUsersInTier(tier)
                Section(header: TierHeader(tier: tier, locked: locked)) {
                    if locked {
                        HStack {
                            Rectangle().fill(tier.color.opacity(0.5)).frame(width: 4).cornerRadius(2)
                            Image(systemName: "lock.fill")
                                .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.7))
                            Text("Reach \(formatSimpleAmount(tier.minNetWorth)) to unlock")
                                .font(Theme.bodyFont())
                                .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.7))
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(glassMorphBackground())
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(Array(usersInTier.enumerated()), id: \.element.username) { index, userProfile in
                            ZStack {
                                NavigationLink {
                                    ProfileView(username: userProfile.username, accent: tier.color)
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)

                                colorCodedRow(
                                    username: userProfile.username,
                                    name: userProfile.username.withoutUsernamePrefix,
                                    amount: userDataManager.formatNetWorth(userProfile.netWorthUSD) + (index == 0 ? " ▲" : ""),
                                    color: tier.color
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                }
            }
        }
#if os(iOS)
        .listStyle(.plain)
#else
        .listStyle(.sidebar)
#endif
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .tint(Theme.accentMuted)
        .environment(\.defaultMinListRowHeight, 64)
        .listSectionSeparator(.hidden)
        .listRowSeparator(.hidden)
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
            .background(glassMorphBackground())
    }

    private func progressSubtitle(current: Tier?, next: Tier?) -> String {
        if let current, let next { return "Progress to \(next.name) Status" }
        if current != nil { return "Top Status achieved" }
        return "Get ranked by growing your net worth"
    }

    private func formatSimpleAmount(_ value: Double) -> String {
        if value >= 1_000_000 {
            let millions = value / 1_000_000
            return "$\(Int(millions))M"
        } else if value >= 1_000 {
            let thousands = value / 1_000
            return "$\(Int(thousands))k"
        } else {
            return "$\(Int(value))"
        }
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
