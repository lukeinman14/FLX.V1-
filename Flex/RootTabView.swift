import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                Text("Home")
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            NavigationStack {
                Text("DMs")
                    .navigationTitle("Messages")
            }
            .tabItem {
                Label("DMs", systemImage: "envelope")
            }

            NavigationStack {
                Text("Activity")
                    .navigationTitle("Activity")
            }
            .tabItem {
                Label("Activity", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                Text("Leaderboard")
                    .navigationTitle("Leaderboard")
            }
            .tabItem {
                Label("Leaderboard", systemImage: "trophy")
            }
        }
    }
}

#Preview {
    RootTabView()
        .preferredColorScheme(.dark)
}
