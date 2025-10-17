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
            
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 24)
                    .contentShape(Rectangle())
                    .position(x: 12, y: geometry.size.height / 2)
                    .allowsHitTesting(!isOpen)
                    .gesture(edgeOpenDrag)
            }

            drawer
                .offset(x: isOpen ? 0 : -width)
                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: isOpen)
        }
        .background(Theme.bg)
    }

    private var drawer: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                // Small owl logo watermark
                OwlLogo()
                    .frame(width: 24, height: 24)
                    .opacity(0.7)
                
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
#if os(iOS)
            .listStyle(.insetGrouped)
#else
            .listStyle(.sidebar)
#endif
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
                if !isOpen && horizontal > 60 {
                    withAnimation(.spring()) { isOpen = true }
                } else if isOpen && horizontal < -60 {
                    withAnimation(.spring()) { isOpen = false }
                }
            }
    }

    private var edgeOpenDrag: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onEnded { value in
                let horizontal = value.translation.width
                if !isOpen && horizontal > 30 {
                    withAnimation(.spring()) { isOpen = true }
                }
            }
    }
}

// MARK: - Simple destination pages

struct ExploreView: View {
    @State private var isRefreshing = false
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
#if os(iOS)
        .listStyle(.insetGrouped)
#else
        .listStyle(.sidebar)
#endif
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle("Explore")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .refreshable {
            isRefreshing = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isRefreshing = false
        }
        .toolbar {
            if isRefreshing {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#else
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#endif
            }
        }
    }
}

struct AppNotificationsScreen: View {
    var body: some View {
        NotificationsView()
            .navigationTitle("Notifications")
    }
}

struct AppSettingsView: View {
    @State private var showLoggedOut = false
    @State private var isRefreshing = false

    var body: some View {
        Form {
            Section("Account") {
                NavigationLink { MyProfileView() } label: { Label("My Profile", systemImage: "person.crop.circle") }
            }
            Section("Account Access") {
                NavigationLink { AuthHomeView().environment(AuthState()) } label: { Label("Log in / Create Account", systemImage: "person.badge.key") }
            }
            Section("Prove Net Worth") {
                NavigationLink { ConnectBankAccountsView() } label: { Label("Connect Bank Accounts", systemImage: "building.columns") }
                NavigationLink { ConnectBrokeragesView() } label: { Label("Connect Brokerages", systemImage: "chart.line.uptrend.xyaxis") }
                NavigationLink { ConnectExchangesView() } label: { Label("Connect Crypto Exchanges", systemImage: "bitcoinsign.circle") }
            }
            Section("Preferences") {
                Toggle("Enable Sounds", isOn: .constant(true))
                Toggle("Haptics", isOn: .constant(true))
            }
            Section("Onboarding") {
                NavigationLink { InterestSelectionView() } label: { Label("Choose Interests", systemImage: "list.bullet.rectangle.portrait") }
            }
            Section("About") {
                Text("Version 1.0")
            }
            Section("Account") {
                Button(role: .destructive) { showLoggedOut = true } label: { Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right") }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .owlRefreshEnabled(false)
        .navigationTitle("Settings")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .refreshable {
            isRefreshing = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            try? await Task.sleep(nanoseconds: 750_000_000)
            isRefreshing = false
        }
        .toolbar {
            if isRefreshing {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#else
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#endif
            }
        }
        .alert("Logged Out", isPresented: $showLoggedOut) { Button("OK", role: .cancel) {} } message: { Text("You have been logged out (demo).") }
    }
}

struct BookmarksView: View {
    @State private var isRefreshing = false

    var body: some View {
        List {
            Section("Saved Posts") {
                ForEach(["Stacking weekly DCA.", "Closed covered calls for 1.8%.", "Rebalancing 70/30."], id: \.self) { post in
                    Text(post).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                        .listRowBackground(Theme.bg)
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
        .navigationTitle("Bookmarks")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .refreshable {
            isRefreshing = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            try? await Task.sleep(nanoseconds: 800_000_000)
            isRefreshing = false
        }
        .toolbar {
            if isRefreshing {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#else
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#endif
            }
        }
    }
}

struct ListsView: View {
    @State private var isRefreshing = false

    var body: some View {
        List {
            Section("Your Lists") {
                ForEach(["Top Traders", "Tech Bulls", "Crypto OGs"], id: \.self) { name in
                    HStack { Text(name).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary); Spacer() }
                        .listRowBackground(Theme.bg)
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
        .navigationTitle("Lists")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .refreshable {
            isRefreshing = true
            #if canImport(UIKit)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            try? await Task.sleep(nanoseconds: 900_000_000)
            isRefreshing = false
        }
        .toolbar {
            if isRefreshing {
#if os(iOS)
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#else
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                }
#endif
            }
        }
    }
}

// MARK: - Example usage of HomeDrawer in a container view

struct HomeDrawerContainerView: View {
    enum HomeDestination: Hashable {
        case explore
        case notifications
        case settings
        case myProfile
    }
    
    @State private var drawerOpen = false
    @State private var path = NavigationPath()
    @State private var isRefreshingHome = false
    @State private var showRefreshBanner = false
    
    @State private var feedItems: [String] = [
        "Welcome to Owl Finance",
        "Your daily market brief",
        "Tap the menu to explore",
        "Top movers: AAPL, NVDA, BTC",
        "Strategy: DCA vs. Lump Sum",
        "Community highlights",
        "Earnings calendar this week",
        "Macro snapshot",
        "Tip: Long-press posts to save",
        "Explore: Crypto sentiment"
    ]
    @State private var feedCounter: Int = 1

    var body: some View {
        NavigationStack(path: $path) {
            HomeDrawer(isOpen: $drawerOpen, items: drawerItems) {
                List {
                    if isRefreshingHome || showRefreshBanner {
                        Section {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(Theme.accentMuted)
                                Text("Refreshing…")
                                    .font(Theme.bodyFont())
                                    .foregroundStyle(Theme.textSecondary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(Theme.bg)
                        }
                    }
                    Section {
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
                        .listRowBackground(Theme.bg)
                    }

                    Section("Feed") {
                        ForEach(feedItems, id: \.self) { item in
                            Text(item)
                                .font(Theme.bodyFont())
                                .foregroundStyle(Theme.textPrimary)
                                .listRowBackground(Theme.bg)
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
                .refreshable {
                    showRefreshBanner = true
                    isRefreshingHome = true
                    #if canImport(UIKit)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    #endif
                    try? await Task.sleep(nanoseconds: 900_000_000)
                    feedCounter += 1
                    feedItems.insert("Refreshed item #\(feedCounter) — \(Date.now.formatted(date: .omitted, time: .shortened))", at: 0)
                    isRefreshingHome = false
                    // Delay hiding the banner slightly so users always see it
                    try? await Task.sleep(nanoseconds: 350_000_000)
                    showRefreshBanner = false
                }
                .toolbar {
                    if isRefreshingHome {
#if os(iOS)
                        ToolbarItem(placement: .topBarTrailing) {
                            ProgressView()
                                .tint(Theme.accentMuted)
                        }
#else
                        ToolbarItem(placement: .primaryAction) {
                            ProgressView()
                                .tint(Theme.accentMuted)
                        }
#endif
                    }
                }
            }
            .navigationDestination(for: HomeDestination.self) { dest in
                switch dest {
                case .explore:
                    ExploreView()
                case .notifications:
                    AppNotificationsScreen()
                case .settings:
                    AppSettingsView()
                case .myProfile:
                    MyProfileView()
                }
            }
        }
    }

    var drawerItems: [DrawerItem] {
        [
            DrawerItem(title: "Explore", systemImage: "safari") {
                withAnimation(.spring()) { drawerOpen = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(HomeDestination.explore) }
            },
            DrawerItem(title: "Notifications", systemImage: "bell") {
                withAnimation(.spring()) { drawerOpen = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(HomeDestination.notifications) }
            },
            DrawerItem(title: "Settings", systemImage: "gearshape") {
                withAnimation(.spring()) { drawerOpen = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(HomeDestination.settings) }
            },
            DrawerItem(title: "My Profile", systemImage: "person.crop.circle") {
                withAnimation(.spring()) { drawerOpen = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { path.append(HomeDestination.myProfile) }
            }
        ]
    }
}

struct ConnectBankAccountsView: View {
    @State private var isConnecting = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Securely connect your bank accounts to verify balances.")
                .font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { isConnecting = true }) {
                Label("Connect with Plaid", systemImage: "link")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Bank Accounts")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .alert("Demo Only", isPresented: $isConnecting) { Button("OK", role: .cancel) {} } message: { Text("Plaid linking UI would appear here in production.") }
    }
}

struct ConnectBrokeragesView: View {
    @State private var isConnecting = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Link your brokerage accounts to import holdings and balances.")
                .font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { isConnecting = true }) {
                Label("Connect with Plaid", systemImage: "link")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Brokerages")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .alert("Demo Only", isPresented: $isConnecting) { Button("OK", role: .cancel) {} } message: { Text("Plaid linking UI would appear here in production.") }
    }
}

struct ConnectExchangesView: View {
    @State private var isConnecting = false
    var body: some View {
        VStack(spacing: 16) {
            Text("Connect crypto exchanges to verify wallet balances.")
                .font(Theme.bodyFont()).foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { isConnecting = true }) {
                Label("Connect with Plaid", systemImage: "link")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.divider, lineWidth: 1)))
            }
            Spacer()
        }
        .padding(16)
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Exchanges")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .alert("Demo Only", isPresented: $isConnecting) { Button("OK", role: .cancel) {} } message: { Text("Plaid linking UI would appear here in production.") }
    }
}

// MARK: - Owl Logo Component
struct OwlLogo: View {
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1.5)
                .opacity(0.8)
            
            // Inner owl design
            VStack(spacing: 1) {
                // Owl ears/horns
                HStack(spacing: 8) {
                    Path { path in
                        path.move(to: CGPoint(x: 2, y: 8))
                        path.addLine(to: CGPoint(x: 6, y: 2))
                        path.addLine(to: CGPoint(x: 8, y: 8))
                    }
                    .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1.2)
                    .frame(width: 10, height: 8)
                    
                    Path { path in
                        path.move(to: CGPoint(x: 2, y: 8))
                        path.addLine(to: CGPoint(x: 4, y: 2))
                        path.addLine(to: CGPoint(x: 8, y: 8))
                    }
                    .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1.2)
                    .frame(width: 10, height: 8)
                }
                
                // Eyes
                HStack(spacing: 4) {
                    Circle()
                        .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1)
                        .frame(width: 4, height: 4)
                    Circle()
                        .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1)
                        .frame(width: 4, height: 4)
                }
                
                // Beak
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 2, y: 4))
                    path.addLine(to: CGPoint(x: 4, y: 0))
                }
                .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1)
                .frame(width: 4, height: 4)
                
                // Body outline
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color(red: 0.1, green: 1.0, blue: 0.4), lineWidth: 1)
                    .frame(width: 8, height: 6)
            }
        }
        .frame(width: 24, height: 24)
    }
}
