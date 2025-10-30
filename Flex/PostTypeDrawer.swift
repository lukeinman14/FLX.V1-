import SwiftUI

enum PostType {
    case thought
    case poll
    case debate
}

struct PostTypeDrawer: View {
    @Binding var isPresented: Bool
    let onSelect: (PostType) -> Void

    var body: some View {
        // Digital web menu only (blur overlay is in RootTabs)
        if isPresented {
            DigitalWebMenu(isPresented: $isPresented, onSelect: { type in
                onSelect(type)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPresented = false
                }
            })
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
        }
    }
}

struct DigitalWebMenu: View {
    @Binding var isPresented: Bool
    let onSelect: (PostType) -> Void
    @State private var animateNodes = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Web network positioned near plus button (bottom-right corner)
                ZStack {
                    // Thought node - rotated 45° (1.5 hours)
                    Button(action: {
                        onSelect(.thought)
                    }) {
                        WebNode(
                            icon: "text.bubble.fill",
                            color: .blue
                        )
                    }
                    .offset(x: animateNodes ? 14.14 : 0, y: animateNodes ? -82.84 : 0)
                    .rotationEffect(.degrees(animateNodes ? 0 : -90))
                    .scaleEffect(animateNodes ? 1 : 0.3)
                    .opacity(animateNodes ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(animateNodes ? 0.1 : 0.0), value: animateNodes)

                    // Poll node - rotated 45° (1.5 hours)
                    Button(action: {
                        onSelect(.poll)
                    }) {
                        WebNode(
                            icon: "chart.bar.fill",
                            color: .yellow
                        )
                    }
                    .offset(x: animateNodes ? -56.57 : 0, y: animateNodes ? -56.57 : 0)
                    .rotationEffect(.degrees(animateNodes ? 0 : -90))
                    .scaleEffect(animateNodes ? 1 : 0.3)
                    .opacity(animateNodes ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(animateNodes ? 0.2 : 0.05), value: animateNodes)

                    // Debate node - rotated 45° (1.5 hours)
                    Button(action: {
                        onSelect(.debate)
                    }) {
                        WebNode(
                            icon: "mic.fill",
                            color: Color(red: 0.58, green: 0.4, blue: 0.75)
                        )
                    }
                    .offset(x: animateNodes ? -82.84 : 0, y: animateNodes ? 14.14 : 0)
                    .rotationEffect(.degrees(animateNodes ? 0 : -90))
                    .scaleEffect(animateNodes ? 1 : 0.3)
                    .opacity(animateNodes ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(animateNodes ? 0.3 : 0.1), value: animateNodes)
                }
                .position(
                    x: geometry.size.width - 42.5, // 20 (trailing padding) + 45/2 (button radius)
                    y: geometry.size.height - 42.5 - 49 - 54 // Lifted 3/4 inch (54 points) higher
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateNodes = true
        }
        .onChange(of: isPresented) { oldValue, newValue in
            if !newValue {
                animateNodes = false
            }
        }
    }
}

struct WebNode: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.3), color.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)

            // Node circle
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 2)

            // Icon
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 40, height: 40)
    }
}

#Preview {
    @Previewable @State var isPresented = true

    ZStack {
        Theme.bg.ignoresSafeArea()

        PostTypeDrawer(isPresented: $isPresented) { type in
            print("Selected: \(type)")
        }
    }
    .preferredColorScheme(.dark)
}
