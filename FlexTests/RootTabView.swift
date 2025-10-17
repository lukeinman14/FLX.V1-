import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeFeedView()
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                DMsView()
            }
            .tabItem {
                Label("DMs", systemImage: "envelope")
            }

            NavigationStack {
                ActivityView()
            }
            .tabItem {
                Label("Activity", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                LeaderboardView()
            }
            .tabItem {
                Label("Leaderboard", systemImage: "trophy")
            }
        }
        .accentColor(FlexTheme.accent)
        .background(screenBG())
        .owlRefreshEnabled()
    }
}
