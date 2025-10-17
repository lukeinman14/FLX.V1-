import SwiftUI

import SwiftUI

@Observable
class AuthState {
    var isLoggedIn: Bool = false
    var email: String? = nil
}

struct AuthHomeView: View {
    @Environment(AuthState.self) private var auth
    var body: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 24)

            // Hero (Owl + Tagline + Headline)
            VStack(spacing: 16) {
                OwlHeroLogo()
                    .frame(width: 260, height: 260)
                    .padding(.top, -10)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Climb.")
                    Text("Compete.")
                    Text("Conquer.")
                }
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundStyle(Theme.accentMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 12)

            // Login options
            Button { mockSignIn(provider: "Apple") } label: {
                Label("Continue with Apple", systemImage: "apple.logo")
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.divider, lineWidth: 1)))
            }

            Button { mockSignIn(provider: "Google") } label: {
                Label("Continue with Google", systemImage: "g.circle")
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.surface).overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.divider, lineWidth: 1)))
            }

            NavigationLink { LoginView() } label: {
                Text("Sign in with Email")
                    .font(Theme.bodyFont())
                    .foregroundStyle(Theme.accentMuted)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 14).stroke(Theme.divider, lineWidth: 1))
            }

            HStack {
                Text("New here?").font(Theme.smallFont()).foregroundStyle(Theme.textSecondary)
                NavigationLink("Create Account") { SignupView() }
                    .font(Theme.smallFont()).foregroundStyle(Theme.accentMuted)
            }

            Spacer()
        }
        .padding(16)
        .background(Theme.bg.ignoresSafeArea())
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        #endif
    }

    func mockSignIn(provider: String) {
        // Demo: instantly sign in
        auth.isLoggedIn = true
        auth.email = provider.lowercased() + "@demo"
    }
}

struct InfinityLogo: View {
    @State private var rotation: Angle = .degrees(0)
    @State private var pulse: Double = 0.0
    @State private var gradientPhase: Double = 0.0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2

            ZStack {
                // Subtle pulsing background circle
                Circle()
                    .fill(Theme.surface)
                    .overlay(Circle().stroke(Theme.divider, lineWidth: 1))
                    .opacity(0.65 + 0.1 * CGFloat(sin(pulse)))
                    .scaleEffect(1.0 + 0.02 * CGFloat(sin(pulse)))

                // Infinity glyph centered
                Text("∞")
                    .font(.system(size: size * 0.5, weight: .heavy, design: .default))
                    .foregroundStyle(LinearGradient(colors: [Theme.accentMuted, Theme.accent], startPoint: .leading, endPoint: .trailing))

                // Dots revolving along the edge of the circle
                ZStack {
                    ForEach(0..<3) { i in
                        let phase = Double(i) / 3.0 * 2 * Double.pi
                        Circle()
                            .fill(Color.white)
                            .frame(width: i == 0 ? 10 : 8, height: i == 0 ? 10 : 8)
                            .offset(x: 0, y: -radius + 8)
                            .rotationEffect(.radians(phase))
                    }
                }
                .rotationEffect(rotation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    pulse = Double.pi * 2
                }
                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    gradientPhase = 360
                }
            }
        }
    }
}

struct OwlHeroLogo: View {
    @State private var rotation: Angle = .degrees(0)
    @State private var pulse: Double = 0

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outerRadius = size / 2 - 2

            ZStack {
                // Concentric rings
                Circle()
                    .stroke(Theme.accentMuted.opacity(0.25), lineWidth: 2)
                    .padding(2)
                Circle()
                    .stroke(Theme.accentMuted.opacity(0.35), lineWidth: 2)
                    .padding(10)
                Circle()
                    .stroke(Theme.accentMuted.opacity(0.15), lineWidth: 2)
                    .padding(18)

                // Owl image from assets (add an image named "owl.hero" to Assets.xcassets).
                // Set Render As: Template Image in the asset to allow tinting, or keep Default to preserve original colors.
                Group {
                    #if canImport(UIKit)
                    if let uiImage = UIImage(named: "owl.hero") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding(size * 0.10)
                            .foregroundStyle(Theme.accentMuted)
                            .opacity(0.9)
                    } else {
                        // Fallback placeholder
                        Text("🦉")
                            .font(.system(size: size * 0.45))
                            .scaleEffect(1.0 + 0.02 * CGFloat(sin(pulse)))
                            .overlay(
                                Text("🦉")
                                    .font(.system(size: size * 0.45))
                                    .foregroundStyle(Theme.accentMuted.opacity(0.15))
                                    .blur(radius: 1.2)
                            )
                    }
                    #else
                    // Fallback placeholder for macOS
                    Text("🦉")
                        .font(.system(size: size * 0.45))
                        .scaleEffect(1.0 + 0.02 * CGFloat(sin(pulse)))
                        .overlay(
                            Text("🦉")
                                .font(.system(size: size * 0.45))
                                .foregroundStyle(Theme.accentMuted.opacity(0.15))
                                .blur(radius: 1.2)
                        )
                    #endif
                }

                // Orbiting dots along the outer ring edge
                ZStack {
                    ForEach(0..<5) { i in
                        let phase = Double(i) / 5.0 * 2 * Double.pi
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: i == 0 ? 8 : 6, height: i == 0 ? 8 : 6)
                            .offset(x: 0, y: -(outerRadius - 6))
                            .rotationEffect(.radians(phase))
                            .shadow(color: .white.opacity(0.2), radius: 2, x: 0, y: 0)
                    }
                }
                .rotationEffect(rotation)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
                    rotation = .degrees(360)
                }
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    pulse = Double.pi * 2
                }
            }
        }
    }
}

struct InfinityShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let scale = min(w, h)
        let midX = rect.midX
        let midY = rect.midY
        let a: CGFloat = scale * 0.22
        let b: CGFloat = scale * 0.28

        // Left loop
        path.move(to: CGPoint(x: midX - a, y: midY))
        path.addCurve(to: CGPoint(x: midX - b, y: midY - a),
                      control1: CGPoint(x: midX - a, y: midY - a),
                      control2: CGPoint(x: midX - b, y: midY - a))
        path.addCurve(to: CGPoint(x: midX, y: midY),
                      control1: CGPoint(x: midX - b, y: midY + a),
                      control2: CGPoint(x: midX - a, y: midY + a))

        // Right loop
        path.addCurve(to: CGPoint(x: midX + b, y: midY - a),
                      control1: CGPoint(x: midX + a, y: midY - a),
                      control2: CGPoint(x: midX + b, y: midY - a))
        path.addCurve(to: CGPoint(x: midX + a, y: midY),
                      control1: CGPoint(x: midX + b, y: midY + a),
                      control2: CGPoint(x: midX + a, y: midY + a))

        return path
    }
}

struct LoginView: View {
    @Environment(AuthState.self) private var auth
    @State private var email = "demo@example.com"
    @State private var password = "password"
    @State private var showError = false

    var body: some View {
        Form {
            Section("Email") { 
                TextField("Email", text: $email)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    #endif
            }
            Section("Password") { SecureField("Password", text: $password) }
            Section { Button("Sign In") { signIn() } }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .navigationTitle("Sign In")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .alert("Invalid Credentials", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Use demo@example.com / password") }
    }

    func signIn() {
        if email.lowercased() == "demo@example.com" && password == "password" {
            auth.isLoggedIn = true
            auth.email = email
        } else {
            showError = true
        }
    }
}

struct SignupView: View {
    @Environment(AuthState.self) private var auth
    @State private var email = "newuser@example.com"
    @State private var password = "password"
    @State private var confirm = "password"
    @State private var showError = false

    var body: some View {
        Form {
            Section("Email") { 
                TextField("Email", text: $email)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    #endif
            }
            Section("Password") { SecureField("Password", text: $password) }
            Section("Confirm Password") { SecureField("Confirm Password", text: $confirm) }
            Section { Button("Create Account") { create() } }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .navigationTitle("Create Account")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .alert("Check Your Input", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Passwords must match and be at least 6 characters.") }
    }

    func create() {
        guard password.count >= 6, password == confirm else { showError = true; return }
        auth.isLoggedIn = true
        auth.email = email
    }
}
