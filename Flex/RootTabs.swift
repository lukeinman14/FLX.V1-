import SwiftUI

struct RootTabs: View {
    var body: some View {
        TabView {
            NavigationStack { FeedDemo() }
                .tabItem { Label("Home", systemImage: "house") }
            NavigationStack { MessagesDemo() }
                .tabItem { Label("DMs", systemImage: "envelope") }
            NavigationStack { ConversationView() }
                .tabItem { Label("Chat", systemImage: "message") }
            NavigationStack { LeaderboardView() }
                .tabItem { Label("Leaderboard", systemImage: "trophy") }
        }
        .tint(Theme.accentMuted)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.bg)
            appearance.shadowColor = UIColor(Theme.divider)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

private struct FeedDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                FeedRow(avatar: Image(systemName: "person"), username: "u/AnonWhale", text: "Every dip feels scary, but wealth is built in the red, not the green.", upvoteScore: "4,1", comments: "823", reposts: "311")
                FeedRow(avatar: Image(systemName: "person"), username: "u/SpiceTrader", text: "Rolled my AMD puts out 2 weeks... market makers always know before we do.", upvoteScore: "2,7", comments: "411", reposts: "155")
                FeedRow(avatar: Image(systemName: "person"), username: "u/ByteNomad", text: "I can’t tell if I’m working for money or if money’s working me.", upvoteScore: "5,3", comments: "1,2k", reposts: "642")
            }
        }
        .background(Theme.bg)
        .navigationTitle("Home")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

private struct MessagesDemo: View {
    var body: some View {
        List {
            ConversationListRow(avatar: Image(systemName: "person.crop.circle"), title: "u/AnonFin", preview: "How did you scale from 100k to 10M? Respect man.", score: "6.1")
                .listRowBackground(Theme.bg)
            ConversationListRow(avatar: Image(systemName: "person.crop.circle.fill"), title: "u/ByteWhale", preview: "Not a chance. Check my growth % today.", score: "2.7")
                .listRowBackground(Theme.bg)
            ConversationListRow(avatar: Image(systemName: "person.crop.circle"), title: "u/SpiceTrader", preview: "Did you see that guy lose 5M on that crypto rug? Insane.", score: "6.4")
                .listRowBackground(Theme.bg)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle("Messages")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
