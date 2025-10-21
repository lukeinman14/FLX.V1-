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
                .overlay {
                    if isOpen {
                        Color.black.opacity(0.3).ignoresSafeArea().onTapGesture { withAnimation(.spring()) { isOpen = false } }
                    }
                }
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
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Add top spacing to push content down (reduced by 10%)
                Spacer()
                    .frame(height: geometry.size.height * 0.0)

                VStack(spacing: 0) {
                    // Spacing to push logo down 5%
                    Spacer()
                        .frame(height: geometry.size.height * 0.05)

                    HStack {
                        Spacer()
                        Button(action: { withAnimation(.spring()) { isOpen = false } }) {
                            Image(systemName: "xmark").font(.system(size: 16, weight: .semibold)).foregroundStyle(Theme.accentMuted)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                    }

                    // Flex Owl Logo
                    HStack {
                        Spacer()
                        Image("flex-owl-logo")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(red: 0.45, green: 0.58, blue: 0.45))
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }

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
                        .listRowBackground(Color.clear)
                    }
                }
#if os(iOS)
                .listStyle(.plain)
#else
                .listStyle(.sidebar)
#endif
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Spacer(minLength: 0)

                // Dark Mode Toggle at bottom
                DarkModeToggle()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
            .frame(width: width)
            .frame(maxHeight: .infinity)
        }
        .frame(width: width)
        .background(.ultraThinMaterial)
        .ignoresSafeArea(edges: .vertical)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 8, y: 0)
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

// MARK: - AppSettings Manager
@Observable
class AppSettings {
    static let shared = AppSettings()
    var isDarkMode: Bool = true
}

struct AppSettingsView: View {
    @State private var showLoggedOut = false
    @State private var isRefreshing = false
    @State private var settings = AppSettings.shared

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

// MARK: - Walking Owl Animation
struct WalkingOwlAnimation: View {
    @State private var owlPosition: CGFloat = -50
    @State private var isWalking = false

    let forestGreen = Color(red: 0.45, green: 0.58, blue: 0.45)

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Branch
                RoundedRectangle(cornerRadius: 2)
                    .fill(forestGreen.opacity(0.6))
                    .frame(height: 4)
                    .offset(y: 30)

                // Animated Owl
                AnimatedOwl(isWalking: isWalking, color: forestGreen)
                    .frame(width: 40, height: 50)
                    .offset(x: owlPosition, y: 5)
            }
        }
        .onAppear {
            // Start walking animation
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                owlPosition = UIScreen.main.bounds.width
            }

            // Walking step animation
            withAnimation(.linear(duration: 0.3).repeatForever(autoreverses: true)) {
                isWalking.toggle()
            }
        }
    }
}

struct AnimatedOwl: View {
    let isWalking: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            // Owl ears/tufts
            HStack(spacing: 8) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 8))
                    path.addLine(to: CGPoint(x: 3, y: 0))
                    path.addLine(to: CGPoint(x: 6, y: 8))
                }
                .stroke(color, lineWidth: 2)
                .frame(width: 6, height: 8)

                Path { path in
                    path.move(to: CGPoint(x: 0, y: 8))
                    path.addLine(to: CGPoint(x: 3, y: 0))
                    path.addLine(to: CGPoint(x: 6, y: 8))
                }
                .stroke(color, lineWidth: 2)
                .frame(width: 6, height: 8)
            }

            // Head with eyes
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 24, height: 24)

                HStack(spacing: 6) {
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                    Circle()
                        .fill(.white)
                        .frame(width: 6, height: 6)
                }

                // Beak
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 2, y: 5))
                    path.addLine(to: CGPoint(x: 4, y: 0))
                }
                .fill(Color.orange.opacity(0.8))
                .frame(width: 4, height: 5)
                .offset(y: 8)
            }

            // Body
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 20, height: 16)

            // Legs (animated walking)
            HStack(spacing: 6) {
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: isWalking ? 8 : 6)
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: isWalking ? 6 : 8)
            }
        }
    }
}

// MARK: - Dark Mode Toggle
struct DarkModeToggle: View {
    @State private var settings = AppSettings.shared
    @State private var isAnimating = false

    let forestGreen = Color(red: 0.45, green: 0.58, blue: 0.45)

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                settings.isDarkMode.toggle()
                isAnimating = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                isAnimating = false
            }
        }) {
            HStack(spacing: 8) {
                // Animated icon
                if settings.isDarkMode {
                    // Moon icon
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 16))
                        .foregroundColor(forestGreen)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                } else {
                    // Sun icon
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(isAnimating ? 180 : 0))
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                }

                Text(settings.isDarkMode ? "Dark Mode" : "Light Mode")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(settings.isDarkMode ? forestGreen : .orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.2),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flex Owl Logo
struct FlexOwlLogo: View {
    let forestGreen = Color(red: 0.45, green: 0.58, blue: 0.45)

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.height

            ZStack {
                // Outer circle
                Circle()
                    .stroke(forestGreen, lineWidth: size * 0.025)
                    .frame(width: size * 0.85, height: size * 0.85)

                // Inner circle
                Circle()
                    .stroke(forestGreen, lineWidth: size * 0.02)
                    .frame(width: size * 0.65, height: size * 0.65)

                // Owl body
                VStack(spacing: 0) {
                    // Ear tufts
                    HStack(spacing: size * 0.08) {
                        // Left ear
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: size * 0.08))
                            path.addLine(to: CGPoint(x: size * 0.03, y: 0))
                            path.addLine(to: CGPoint(x: size * 0.06, y: size * 0.08))
                        }
                        .stroke(forestGreen, lineWidth: size * 0.015)

                        // Right ear
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: size * 0.08))
                            path.addLine(to: CGPoint(x: size * 0.03, y: 0))
                            path.addLine(to: CGPoint(x: size * 0.06, y: size * 0.08))
                        }
                        .stroke(forestGreen, lineWidth: size * 0.015)
                    }
                    .offset(y: -size * 0.15)

                    // Eyes (angry/wise expression)
                    HStack(spacing: size * 0.06) {
                        // Left eye
                        ZStack {
                            Circle()
                                .stroke(forestGreen, lineWidth: size * 0.015)
                                .frame(width: size * 0.12, height: size * 0.12)
                            // Pupil
                            Circle()
                                .fill(forestGreen)
                                .frame(width: size * 0.05, height: size * 0.05)
                        }

                        // Right eye
                        ZStack {
                            Circle()
                                .stroke(forestGreen, lineWidth: size * 0.015)
                                .frame(width: size * 0.12, height: size * 0.12)
                            // Pupil
                            Circle()
                                .fill(forestGreen)
                                .frame(width: size * 0.05, height: size * 0.05)
                        }
                    }
                    .offset(y: -size * 0.08)

                    // Beak
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: size * 0.025, y: size * 0.05))
                        path.addLine(to: CGPoint(x: size * 0.05, y: 0))
                    }
                    .stroke(forestGreen, lineWidth: size * 0.015)
                    .offset(y: -size * 0.02)

                    // "FLEX" text on body
                    Text("FLEX")
                        .font(.system(size: size * 0.12, weight: .bold, design: .monospaced))
                        .foregroundColor(forestGreen)
                        .offset(y: size * 0.08)

                    // Wing with feather detail
                    ZStack {
                        // Wing outline
                        Path { path in
                            path.move(to: CGPoint(x: size * 0.15, y: 0))
                            path.addCurve(
                                to: CGPoint(x: size * 0.05, y: size * 0.25),
                                control1: CGPoint(x: size * 0.02, y: size * 0.08),
                                control2: CGPoint(x: 0, y: size * 0.18)
                            )
                        }
                        .stroke(forestGreen, lineWidth: size * 0.015)

                        // Feather lines
                        VStack(spacing: size * 0.015) {
                            ForEach(0..<4) { i in
                                Path { path in
                                    let yOffset = CGFloat(i) * size * 0.05
                                    path.move(to: CGPoint(x: size * 0.08, y: yOffset))
                                    path.addLine(to: CGPoint(x: size * 0.13, y: yOffset + size * 0.02))
                                }
                                .stroke(forestGreen, lineWidth: size * 0.01)
                            }
                        }
                        .offset(x: -size * 0.05, y: size * 0.08)
                    }
                    .offset(x: -size * 0.12, y: size * 0.15)

                    // Feet
                    HStack(spacing: size * 0.08) {
                        // Left foot
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: size * 0.02, y: size * 0.04))
                            path.addLine(to: CGPoint(x: size * 0.04, y: size * 0.04))
                        }
                        .stroke(forestGreen, lineWidth: size * 0.012)

                        // Right foot
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addLine(to: CGPoint(x: size * 0.02, y: size * 0.04))
                            path.addLine(to: CGPoint(x: size * 0.04, y: size * 0.04))
                        }
                        .stroke(forestGreen, lineWidth: size * 0.012)
                    }
                    .offset(y: size * 0.35)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
