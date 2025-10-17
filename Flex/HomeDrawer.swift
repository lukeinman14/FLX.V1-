import SwiftUI

struct DrawerItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let action: () -> Void
}

struct HomeDrawer<Content: View>: View {
    @Binding var isOpen: Bool
    let width: CGFloat
    let items: [DrawerItem]
    let content: Content

    @GestureState private var dragOffset: CGFloat = 0

    init(isOpen: Binding<Bool>, width: CGFloat = 280, items: [DrawerItem], @ViewBuilder content: () -> Content) {
        self._isOpen = isOpen
        self.width = width
        self.items = items
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .leading) {
            content
                .disabled(isOpen)
                .overlay { if isOpen { Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { withAnimation(.spring()) { isOpen = false } } } }
                .gesture(mainDrag)

            drawer
                .offset(x: isOpen ? 0 : -width)
                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isOpen)
        }
        .background(Theme.bg)
    }

    private var drawer: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Quick Access")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.accentMuted)
                Spacer()
                Button(action: { withAnimation(.spring()) { isOpen = false } }) {
                    Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.accentMuted)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.bg)
            .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)

            List {
                ForEach(items) { item in
                    Button(action: {
                        withAnimation(.spring()) { isOpen = false }
                        item.action()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: item.systemImage).foregroundStyle(Theme.accentMuted)
                            Text(item.title).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 14, weight: .semibold)).foregroundStyle(Theme.divider)
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Theme.bg)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Theme.bg)
            Spacer(minLength: 0)
        }
        .frame(width: width)
        .frame(maxHeight: .infinity)
        .background(Theme.surfaceElevated)
        .overlay(Rectangle().frame(width: 1).foregroundStyle(Theme.divider), alignment: .trailing)
        .ignoresSafeArea(edges: .vertical)
        .shadow(color: .black.opacity(0.25), radius: 12, x: 8, y: 0)
    }

    private var mainDrag: some Gesture {
        DragGesture(minimumDistance: 15, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let horizontal = value.translation.width
                if !isOpen && horizontal < -60 { // swipe left to open
                    withAnimation(.spring()) { isOpen = true }
                } else if isOpen && horizontal > 60 { // swipe right to close
                    withAnimation(.spring()) { isOpen = false }
                }
            }
    }
}

// MARK: - Simple destination pages

struct ExploreView: View {
    var body: some View {
        List {
            Section("Trending") {
                ForEach(["AAPL", "NVDA", "BTC", "ETH"], id: \.self) { sym in
                    NavigationLink { StockChatView(symbol: sym) } label: {
                        HStack { Text("$\(sym)").font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary); Spacer() }
                    }
                    .listRowBackground(Theme.bg)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle("Explore")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct AppNotificationsView: View {
    var body: some View {
        NotificationsView()
            .navigationTitle("Notifications")
    }
}

struct AppSettingsView: View {
    @Environment(\.[PlayerState.self]) private var player
    var body: some View {
        Form {
            Section("Account") {
                NavigationLink { MyProfileView() } label: { Label("My Profile", systemImage: "person.crop.circle") }
            }
            Section("Preferences") {
                Toggle("Enable Sounds", isOn: .constant(true))
                Toggle("Haptics", isOn: .constant(true))
            }
            Section("About") {
                Text("Version 1.0")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .navigationTitle("Settings")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Example usage of HomeDrawer in a container view

struct HomeDrawerContainerView: View {
    @State private var drawerOpen = false
    @State private var navigationTag: String? = nil

    var body: some View {
        NavigationStack {
            HomeDrawer(isOpen: $drawerOpen, items: drawerItems) {
                VStack {
                    HStack {
                        Button {
                            withAnimation(.spring()) { drawerOpen.toggle() }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundStyle(Theme.accentMuted)
                        }
                        Spacer()
                    }
                    .padding()
                    Spacer()
                    Text("Main Content Area")
                        .font(Theme.headingFont())
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                }
                .navigationDestination(for: String.self) { tag in
                    switch tag {
                    case "Explore":
                        ExploreView()
                    case "Notifications":
                        AppNotificationsView()
                    case "Settings":
                        AppSettingsView()
                    case "MyProfile":
                        MyProfileView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }

    var drawerItems: [DrawerItem] {
        [
            DrawerItem(title: "Explore", systemImage: "safari") {
                navigationTag = "Explore"
            },
            DrawerItem(title: "Notifications", systemImage: "bell") {
                navigationTag = "Notifications"
            },
            DrawerItem(title: "Settings", systemImage: "gearshape") {
                navigationTag = "Settings"
            },
            DrawerItem(title: "My Profile", systemImage: "person.crop.circle") {
                navigationTag = "MyProfile"
            }
        ]
    }
}

// MARK: - Dummy views for completeness

struct StockChatView: View {
    let symbol: String
    var body: some View {
        Text("Chat for \(symbol)")
            .navigationTitle(symbol)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Notifications Content")
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyProfileView: View {
    var body: some View {
        Text("My Profile Page")
            .navigationTitle("My Profile")
            .navigationBarTitleDisplayMode(.inline)
    }
}
