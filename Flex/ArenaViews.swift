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
    @State private var bets: [Bet] = [
        Bet(challenger: "u/AnonWhale", opponent: "u/ByteNomad", xpWager: 250, goal: "Highest % gain this week", daysLeft: 5),
        Bet(challenger: "u/MuadDib", opponent: "u/HarkonnenHold", xpWager: 100, goal: "+3% growth in 7 days", daysLeft: 3)
    ]
    @State private var showCreate = false

    var body: some View {
        VStack(spacing: 0) {
            header
            List {
                Section("Active Bets") {
                    ForEach(bets) { bet in
                        NavigationLink {
                            BetDetailView(bet: bet)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "swords")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(Theme.accent, Theme.textSecondary)
                                    .font(.system(size: 22, weight: .semibold))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(bet.challenger) vs \(bet.opponent)")
                                        .font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                                    Text(bet.goal)
                                        .font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                                }
                                Spacer()
                                Text("\(bet.xpWager) XP")
                                    .font(Theme.smallFont()).foregroundStyle(Theme.accentMuted)
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Theme.bg)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)

            Button { showCreate = true } label: {
                Label("Create XP Wager", systemImage: "plus.circle.fill")
                    .foregroundStyle(Theme.accentMuted)
                    .font(Theme.headingFont())
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .sheet(isPresented: $showCreate) {
            CreateBetView { newBet in
                bets.insert(newBet, at: 0)
                player.xp -= max(0, newBet.xpWager / 10) // small posting fee demo
            }
            .presentationDetents([.medium])
        }
        .navigationTitle("Activity")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
                .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
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
    var body: some View {
        VStack(spacing: 16) {
            Text("VICTORY!")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accent)
            Text("Arena Challenge Complete").font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.accent)
                VStack(alignment: .leading) {
                    Text("u/You").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                    Text("+\(bet.xpWager) XP").font(Theme.bodyFont()).foregroundStyle(Theme.accent)
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
        .background(Theme.bg)
    }
}
