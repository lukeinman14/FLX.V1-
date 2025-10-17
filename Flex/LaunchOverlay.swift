import SwiftUI

struct LaunchOverlay: View {
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.7
    @State private var glow: Double = 0
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 24) {
                // Logo resembling the app (finance + chat): bubble with chart line
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Theme.surfaceElevated)
                        .frame(width: 120, height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.accentMuted, lineWidth: 1.5))
                        .shadow(color: Theme.accent.opacity(0.25), radius: 18)
                    Image(systemName: "bubble.left.and.text.bubble.right.fill")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .offset(y: -8)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Theme.accentMuted)
                        .offset(y: 26)
                }
                .scaleEffect(scale)
                .shadow(color: Theme.accent.opacity(glow), radius: 24)

                // Progress shimmer
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
                        .frame(height: 10)
                        .frame(width: 220)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Theme.accentMuted, Theme.accent], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 220 * progress, height: 10)
                }
                Text("Flex is loading...")
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .onAppear { animate() }
        .accessibilityLabel("Loading")
    }

    private func animate() {
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) { scale = 1.0 }
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { glow = 0.5 }
        withAnimation(.easeInOut(duration: 1.2)) { progress = 1.0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.easeOut(duration: 0.35)) { isPresented = false }
        }
    }
}

#Preview {
    @Previewable @State var show = true
    return LaunchOverlay(isPresented: $show)
        .preferredColorScheme(.dark)
}
