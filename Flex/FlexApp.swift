//
//  FlexApp.swift
//  Flex
//
//  Created by Luke Inman on 10/9/25.
//

import SwiftUI

@main
struct FlexApp: App {
    @StateObject private var stockService = StockAPIService.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootTabs()
            }
            .environmentObject(stockService)
            .task {
                // Startup API sanity check: fetch a known symbol and log whether live data is used
                await StockAPIService.shared.fetchStockData(symbol: "BTC")
                if let data = StockAPIService.shared.stockCache["BTC"] {
                    let age = Date().timeIntervalSince(data.lastUpdated)
                    print("[FlexApp] Startup check: fetched BTC. lastUpdated=\(Int(age))s ago, points=\(data.chartData.count)")
                } else {
                    print("[FlexApp] Startup check: BTC not found in cache after fetch.")
                }
            }
            .owlRefreshEnabled(true)
            .preferredColorScheme(.dark)
        }
    }
}

struct LiveDataStatusPill: View {
    @EnvironmentObject private var stockService: StockAPIService
    let symbol: String

    var body: some View {
        let isLive = stockService.isLiveData[symbol] ?? false
        let text = isLive ? "Live" : "Mock"
        let color: Color = isLive ? Color.green.opacity(0.85) : Color.orange.opacity(0.85)

        return Text("\(text) • \(symbol)")
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(RoundedRectangle(cornerRadius: 12).fill(color))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
            .foregroundColor(.black)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            .accessibilityLabel(isLive ? "Live data for \(symbol)" : "Mock data for \(symbol)")
    }
}
