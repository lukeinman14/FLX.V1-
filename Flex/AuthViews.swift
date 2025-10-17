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
            Spacer(minLength: 20)
            Text("Welcome")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
            Text("Create an account or sign in to sync your profile and prove net worth.")
                .font(Theme.smallFont())
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

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
        .navigationTitle("Account")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    func mockSignIn(provider: String) {
        // Demo: instantly sign in
        auth.isLoggedIn = true
        auth.email = provider.lowercased() + "@demo"
    }
}

struct LoginView: View {
    @Environment(AuthState.self) private var auth
    @State private var email = "demo@example.com"
    @State private var password = "password"
    @State private var showError = false

    var body: some View {
        Form {
            Section("Email") { TextField("Email", text: $email).textInputAutocapitalization(.never).autocorrectionDisabled() }
            Section("Password") { SecureField("Password", text: $password) }
            Section { Button("Sign In") { signIn() } }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .navigationTitle("Sign In")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
            Section("Email") { TextField("Email", text: $email).textInputAutocapitalization(.never).autocorrectionDisabled() }
            Section("Password") { SecureField("Password", text: $password) }
            Section("Confirm Password") { SecureField("Confirm Password", text: $confirm) }
            Section { Button("Create Account") { create() } }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.accentMuted)
        .navigationTitle("Create Account")
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Check Your Input", isPresented: $showError) { Button("OK", role: .cancel) {} } message: { Text("Passwords must match and be at least 6 characters.") }
    }

    func create() {
        guard password.count >= 6, password == confirm else { showError = true; return }
        auth.isLoggedIn = true
        auth.email = email
    }
}
