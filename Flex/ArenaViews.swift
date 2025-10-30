import SwiftUI

struct Bet: Identifiable {
    let id = UUID()
    var challenger: String
    var opponent: String
    var xpWager: Int
    var goal: String // e.g., "Highest % portfolio gain in a week"
    var daysLeft: Int
}

struct ArenaListView: View {
    @Environment(PlayerState.self) private var player
    @Environment(\.colorScheme) private var colorScheme
    @State private var bets: [Bet] = [
        Bet(challenger: "u/AnonWhale", opponent: "u/ByteNomad", xpWager: 250, goal: "Highest % gain this week", daysLeft: 5),
        Bet(challenger: "u/MuadDib", opponent: "u/HarkonnenHold", xpWager: 100, goal: "+3% growth in 7 days", daysLeft: 3)
    ]
    @State private var showCreate = false

    var body: some View {
        let progressInfo = GamificationModel.demo.nextTierProgress(for: player.profile)
        let currentTier = GamificationModel.demo.currentTier(for: player.profile)

        NavigationStack {
            List {
                Section {
                    NetWorthChart(
                        currentNetWorth: player.profile.netWorthUSD,
                        nextTierThreshold: progressInfo.next?.minNetWorth ?? 100_000,
                        nextTierName: progressInfo.next?.name ?? "Gold"
                    )
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowSeparator(.hidden)
                }

                Section("Your Holdings") {
                    ForEach([Holding(symbol: "AAPL", amount: "120 sh", value: "$22k"), Holding(symbol: "BTC", amount: "0.8", value: "$52k")]) { h in
                        NavigationLink { StockChatView(symbol: h.symbol) } label: {
                            HStack {
                                Text(h.symbol).font(Theme.bodyFont().weight(.semibold)).foregroundStyle(Theme.textPrimary)
                                Spacer()
                                Text(h.amount).font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                                Text(h.value).font(Theme.bodyFont()).foregroundStyle(Theme.accentMuted)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .background(liquidGlassRoundedRect(cornerRadius: 12))
                        .listRowSeparator(.hidden)
                    }
                }

                Section("Active Bets") {
                    ForEach(bets) { bet in
                        NavigationLink {
                            BetDetailView(bet: bet)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "crossed.swords")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Theme.accent, Theme.textSecondary)
                                    .font(.system(size: 22, weight: .semibold))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(bet.challenger) vs \(bet.opponent)")
                                        .font(Theme.bodyFont().weight(.semibold)).foregroundStyle(Theme.textPrimary)
                                    Text(bet.goal)
                                        .font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                Text("\(bet.xpWager) XP")
                                    .font(Theme.smallFont().weight(.semibold)).foregroundStyle(Theme.accentMuted)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                        }
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                        .background(liquidGlassRoundedRect(cornerRadius: 12))
                        .listRowSeparator(.hidden)
                    }
                }
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #else
            .listStyle(.sidebar)
            #endif
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
                        Text("Activity")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        Spacer()
                    }
                    .frame(height: 52)

                    // Header badges (500 XP, 3 day streak, check-in)
                    header
                }
            }
            .navigationTitle("Activity")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(true)
            #endif
        }
        .background(Theme.bg.ignoresSafeArea())
        .sheet(isPresented: $showCreate) {
            CreateBetView { newBet in
                bets.insert(newBet, at: 0)
                player.xp -= max(0, newBet.xpWager / 10) // small posting fee demo
            }
            #if os(iOS)
            .presentationDetents([.medium])
            #endif
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            XPBadge(xp: player.xp)
            StreakBadge(streak: player.dailyStreak)
            Spacer()
            Button("Check-in") { player.checkInToday() }
                .font(Theme.smallFont())
                .foregroundStyle(Theme.accentMuted)
                .padding(8)
                .background(liquidGlassRoundedRect(cornerRadius: 10))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
        .background(liquidGlassRoundedRect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func liquidGlassRoundedRect(cornerRadius: CGFloat) -> some View {
        ZStack {
            // Base blur/material for distortion effect (like tab bar)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)

            // Subtle tint overlay
            RoundedRectangle(cornerRadius: cornerRadius)
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
            RoundedRectangle(cornerRadius: cornerRadius)
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
}

struct CreateBetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var opponent = "u/ByteNomad"
    @State private var xp = 250
    @State private var goal = "Highest % portfolio gain in a week"

    var onCreate: (Bet) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Opponent") { TextField("Username", text: $opponent) }
                Section("Wager") { Stepper("\(xp) XP", value: $xp, in: 50...5_000, step: 50) }
                Section("Goal") { TextField("Goal", text: $goal) }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            .tint(Theme.accentMuted)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(Bet(challenger: "u/You", opponent: opponent, xpWager: xp, goal: goal, daysLeft: 7))
                        dismiss()
                    }
                }
            }
        }
    }
}

struct BetDetailView: View {
    let bet: Bet
    @Environment(PlayerState.self) private var player
    @State private var showVictory = false

    var body: some View {
        VStack(spacing: 16) {
            Text(bet.goal).font(Theme.headingFont()).foregroundStyle(Theme.accentMuted)
            Text("Wager: \(bet.xpWager) XP").font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
            Spacer()
            Button {
                showVictory = true
                player.xp += bet.xpWager // demo: you win
            } label: {
                Text("End Match — I Won")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))
            }
        }
        .padding(16)
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Arena")
        .sheet(isPresented: $showVictory) { VictoryView(bet: bet) }
    }
}

struct VictoryView: View {
    let bet: Bet
    @State private var confetti = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("VICTORY!")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.accent)
                Text("Arena Challenge Complete").font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)

                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("u/You").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                        HStack(spacing: 8) {
                            Text("+\(bet.xpWager) XP").font(Theme.bodyFont()).foregroundStyle(Theme.accent)
                            RankUpBadge()
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))

                Spacer()
                Button("Share Victory") {}
                    .font(Theme.bodyFont())
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Theme.divider, lineWidth: 1))
            }
            .padding(20)

            if confetti { ConfettiView().ignoresSafeArea() }
        }
        .onAppear { celebrate() }
    }

    func celebrate() {
        #if canImport(UIKit)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { confetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.6)) { confetti = false }
        }
    }
}

struct RankUpBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.up.right.circle.fill").foregroundStyle(Theme.accent)
            Text("+1 RANK UP").font(Theme.smallFont()).foregroundStyle(Theme.textPrimary)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surfaceElevated).overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1)))
    }
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = (0..<80).map { _ in ConfettiPiece() }
    var body: some View {
        GeometryReader { geo in
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size.width, height: piece.size.height)
                    .rotationEffect(piece.rotation)
                    .position(x: piece.position.x * geo.size.width, y: piece.position.y * geo.size.height)
                    .animation(.interpolatingSpring(stiffness: 40, damping: 8).delay(piece.delay), value: piece.position)
            }
            .onAppear {
                for i in pieces.indices {
                    pieces[i].position.y = 1.2
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint = CGPoint(x: Double.random(in: 0...1), y: -0.2)
    var size: CGSize = CGSize(width: Double.random(in: 4...8), height: Double.random(in: 8...16))
    var rotation: Angle = .degrees(Double.random(in: 0...360))
    var color: Color = [Color.red, .orange, .yellow, .green, .blue, .purple].randomElement()!
    var delay: Double = Double.random(in: 0...0.6)
}

