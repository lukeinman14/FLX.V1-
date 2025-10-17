import SwiftUI

@main
struct FlexApp: App {
    var body: some Scene {
        WindowGroup {
            RootWithSplash()
        }
    }
}

struct RootWithSplash: View {
    @State private var showSplash: Bool = true

    var body: some View {
        ZStack {
            RootTabView()
                .opacity(showSplash ? 0 : 1)
            if showSplash {
                SplashView()
                    .transition(.opacity.combined(with: .scale))
                    .onAppear {
                        // Keep splash for a short moment, then fade
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeOut(duration: 0.4)) {
                                showSplash = false
                            }
                        }
                    }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct FlexTheme {
    static let bg = Color(red: 0.03, green: 0.07, blue: 0.07)
    static let card = Color(red: 0.06, green: 0.12, blue: 0.11)
    static let accent = Color(red: 0.46, green: 0.96, blue: 0.84)
    static let secondary = Color(red: 0.35, green: 0.75, blue: 0.68)
    static let line = Color(red: 0.12, green: 0.2, blue: 0.18)
    static let textPrimary = Color(red: 0.78, green: 0.96, blue: 0.9)
    static let textSecondary = Color(red: 0.55, green: 0.8, blue: 0.73)

    struct Fonts {
        static let title = Font.system(size: 24, weight: .bold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    }
}

extension View {
    func neonStroke() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(FlexTheme.accent.opacity(0.3), lineWidth: 1)
        )
    }

    @available(iOS 17.0, *)
    func screenBG() -> some View {
        self.background(FlexTheme.bg).scrollContentBackground(.hidden)
    }
    
    // Fallback for earlier iOS versions
    func screenBG() -> some View {
        self.background(FlexTheme.bg)
    }
}
