import SwiftUI
import FlexTheme

struct Thread: Identifiable {
    let id = UUID()
    let avatar: String
    let handle: String
    let lastMessage: String
    let unreadCount: Int
    let messages: [Message]
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSpecial: Bool
    let isCurrentUser: Bool
}

struct MockData {
    static let threads = [
        Thread(
            avatar: "person.circle.fill",
            handle: "@alice",
            lastMessage: "Hey, how are you?",
            unreadCount: 2,
            messages: [
                Message(text: "Hey, how are you?", isSpecial: false, isCurrentUser: false),
                Message(text: "I'm good, thanks!", isSpecial: true, isCurrentUser: true)
            ]
        ),
        Thread(
            avatar: "person.circle.fill",
            handle: "@bob",
            lastMessage: "Let's meet tomorrow.",
            unreadCount: 0,
            messages: [
                Message(text: "Let's meet tomorrow.", isSpecial: false, isCurrentUser: false),
                Message(text: "Sure thing.", isSpecial: false, isCurrentUser: true)
            ]
        )
    ]
}

struct DMsView: View {
    @State private var searchText = ""
    
    var filteredThreads: [Thread] {
        if searchText.isEmpty {
            return MockData.threads
        } else {
            return MockData.threads.filter {
                $0.handle.localizedCaseInsensitiveContains(searchText) ||
                $0.lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Messages")
                    .font(.largeTitle.bold())
                    .padding(.top, 44)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .foregroundColor(FlexTheme.accent)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(FlexTheme.accent.opacity(0.6))
                    TextField("Search", text: $searchText)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.none)
                        .foregroundColor(FlexTheme.accent)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(FlexTheme.card)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                
                List {
                    ForEach(filteredThreads) { thread in
                        NavigationLink(value: thread) {
                            HStack(spacing: 16) {
                                Image(systemName: thread.avatar)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(FlexTheme.accent)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(thread.handle)
                                        .fontWeight(.semibold)
                                        .foregroundColor(FlexTheme.accent)
                                    Text(thread.lastMessage)
                                        .font(.subheadline)
                                        .foregroundColor(FlexTheme.accent.opacity(0.7))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if thread.unreadCount > 0 {
                                    Text("\(thread.unreadCount)")
                                        .font(.caption2.bold())
                                        .foregroundColor(.white)
                                        .frame(width: 18, height: 18)
                                        .background(
                                            Circle()
                                                .fill(FlexTheme.accent)
                                        )
                                }
                            }
                            .padding(.vertical, 8)
                            .listRowBackground(FlexTheme.background)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(FlexTheme.background)
            }
            .background(FlexTheme.background.ignoresSafeArea())
            .navigationDestination(for: Thread.self) { thread in
                ChatView(thread: thread)
            }
        }
    }
}

struct ChatView: View {
    let thread: Thread
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(thread.messages) { message in
                            HStack {
                                if message.isCurrentUser {
                                    Spacer()
                                }
                                
                                Text(message.text)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(FlexTheme.card)
                                            .overlay(
                                                message.isSpecial ?
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(FlexTheme.neonStroke, lineWidth: 2)
                                                : nil
                                            )
                                    )
                                    .foregroundColor(FlexTheme.accent)
                                
                                if !message.isCurrentUser {
                                    Spacer()
                                }
                            }
                            .padding(message.isCurrentUser ? .leading : .trailing, 80)
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(FlexTheme.background)
            }
        }
        .navigationTitle(thread.handle)
        .navigationBarTitleDisplayMode(.inline)
        .background(FlexTheme.background.ignoresSafeArea())
    }
}

struct DMsView_Previews: PreviewProvider {
    static var previews: some View {
        FlexThemePreview {
            DMsView()
        }
    }
}
