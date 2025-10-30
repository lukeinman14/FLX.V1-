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
    @Environment(\.colorScheme) private var colorScheme

    private var items: [NotificationItem] = [
        .init(icon: "swords", title: "u/MuadDib and u/HarkonnenHold just entered Arena Mode", subtitle: "Arena Challenge Activated – First to +3% growth wins.", category: .all),
        .init(icon: "diamond.fill", title: "u/FremenFlow advanced to Diamond Tier", subtitle: nil, category: .rank),
        .init(icon: "number.circle", title: "u/ByteNomad moved up 3 ranks to #7 on Leaderboard", subtitle: nil, category: .rank),
        .init(icon: "at", title: "@You You were mentioned by u/SpiceTrader", subtitle: "Rolling puts always feels risky ... respect", category: .mentions),
        .init(icon: "heart.fill", title: "u/AnonWhale liked your Thought", subtitle: "Wealth is built in the red, not the green", category: .all)
    ]

    var body: some View {
        NavigationStack {
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
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
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
                        Text("Notifications")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        Spacer()
                    }
                    .frame(height: 52)

                    // Segmented buttons with liquid glass styling
                    segmented
                }
            }
            .navigationTitle("Notifications")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            #endif
        }
        .background(Theme.bg.ignoresSafeArea())
    }

    private var segmented: some View {
        HStack(spacing: 12) {
            seg("All", .all)
            seg("Mentions", .mentions)
            seg("Rank", .rank)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func seg(_ title: String, _ cat: NotificationItem.Category) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selection = cat }
        } label: {
            Text(title)
                .font(.system(size: 14, weight: selection == cat ? .semibold : .medium))
                .foregroundStyle(selection == cat ? (colorScheme == .dark ? .white : Theme.textPrimary) : Theme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Group {
                        if selection == cat {
                            liquidGlassButton()
                        }
                    }
                )
        }
    }

    @ViewBuilder
    private func liquidGlassButton() -> some View {
        ZStack {
            // Base blur/material for distortion effect (like tab bar)
            Capsule()
                .fill(.ultraThinMaterial)

            // Subtle tint overlay
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Glass border
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        }
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
    }

    private func filtered(_ items: [NotificationItem]) -> [NotificationItem] {
        switch selection {
        case .all: return items
        case .mentions: return items.filter { $0.category == .mentions }
        case .rank: return items.filter { $0.category == .rank }
        }
    }
}
