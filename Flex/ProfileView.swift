import SwiftUI

struct Holding: Identifiable { let id = UUID(); var symbol: String; var amount: String; var value: String }
struct BankAccount { var balance: String }

struct ProfileView: View {
    var username: String
    var accent: Color = Theme.accentMuted

    @State private var timeframe: Timeframe = .weekly
    enum Timeframe: String, CaseIterable { case daily = "Daily", weekly = "Weekly", monthly = "Monthly", yearly = "Yearly" }

    private let netWorth: String = "$8.45 M"
    private let gain: [Timeframe: String] = [.daily: "+0.6%", .weekly: "+2.3%", .monthly: "+6.1%", .yearly: "+24%"]
    private let holdings: [Holding] = [
        Holding(symbol: "AAPL", amount: "1,250 sh", value: "$237k"),
        Holding(symbol: "NVDA", amount: "300 sh", value: "$370k"),
        Holding(symbol: "BTC", amount: "2.1", value: "$138k"),
        Holding(symbol: "ETH", amount: "25", value: "$78k")
    ]
    private let bank = BankAccount(balance: "$125,000")
    private let posts: [String] = [
        "Every dip feels scary, but wealth is built in the red, not the green.",
        "Rolling puts always feels risky ... respect.",
        "I can’t tell if I’m working for money or if money’s working me."
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                metrics
                accounts
                holdingsList
                postsList
            }
            .padding(.bottom, 20)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(username)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle").font(.system(size: 42)).foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 4) {
                Text(username).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                HStack(spacing: 8) {
                    Text("Net Worth").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                    Text(netWorth).font(Theme.bodyFont()).foregroundStyle(accent)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var metrics: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Portfolio Gain").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
                Spacer()
                timeframePicker
            }
            HStack {
                Text(gain[timeframe] ?? "+0.0%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.surface)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
                .frame(height: 12)
                .overlay(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(LinearGradient(colors: [accent.opacity(0.7), accent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 160)
                }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surfaceElevated))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        .padding(.horizontal, 16)
    }

    private var timeframePicker: some View {
        Menu(timeframe.rawValue) {
            ForEach(Timeframe.allCases, id: \.self) { tf in
                Button(tf.rawValue) { timeframe = tf }
            }
        }
        .font(Theme.smallFont())
        .foregroundStyle(Theme.accentMuted)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
    }

    private var accounts: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Bank Balance").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text(bank.balance).font(Theme.headingFont()).foregroundStyle(Theme.textPrimary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text("Tier").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                Text("GOLD").font(Theme.headingFont()).foregroundStyle(accent)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }

    private var holdingsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Holdings").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary).padding(.horizontal, 16)
            ForEach(holdings) { h in
                HStack {
                    Text(h.symbol).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(h.amount).font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                    Text(h.value).font(Theme.bodyFont()).foregroundStyle(accent)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(Theme.surface)
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
            }
        }
        .background(Theme.bg)
    }

    private var postsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Posts").font(Theme.headingFont()).foregroundStyle(Theme.textPrimary).padding(.horizontal, 16)
            ForEach(posts, id: \.self) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text(post).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                    HStack(spacing: 18) {
                        Text("5.3k")
                        Text("1.2k comments")
                        Text("642 reposts")
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
    NavigationStack { ProfileView(username: "u AnonFin") }
        .preferredColorScheme(.dark)
}
