import SwiftUI

private struct PullOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        // Keep the smallest (most negative) value to detect pull offset
        value = min(value, nextValue())
    }
}

public struct OwlRefreshContainer<Content: View>: View {
    @State private var pullOffset: CGFloat = 0
    @State private var isRefreshing = false
    @State private var rotationBounce = false

    private let onRefresh: () async -> Void
    private let content: Content

    public init(onRefresh: @escaping () async -> Void,
                @ViewBuilder content: () -> Content) {
        self.onRefresh = onRefresh
        self.content = content()
    }

    public var body: some View {
        ScrollView(.vertical) {
            // Owl image overlay at top
            OwlRefreshView(progress: pullProgress, isRefreshing: isRefreshing, rotationBounce: rotationBounce)
                .frame(height: 80)
                .padding(.bottom, -20)
                .zIndex(1)

            content
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: PullOffsetPreferenceKey.self, value: geo.frame(in: .named("ScrollViewCoordinateSpace")).minY)
                    }
                )
        }
        .coordinateSpace(name: "ScrollViewCoordinateSpace")
        .onPreferenceChange(PullOffsetPreferenceKey.self) { value in
            // value is the minY of content inside scrollview coordinate space
            // When pulling down, value > 0 or smaller negative means user is pulling
            if !isRefreshing {
                // Compute pullOffset as positive value, clamped
                let offset = max(0, -value + 80)
                pullOffset = offset
            }
        }
        .refreshable {
            isRefreshing = true
            // Start bounce animation
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                rotationBounce = true
            }
            await onRefresh()
            // End bounce animation and refreshing state
            rotationBounce = false
            isRefreshing = false
            pullOffset = 0
        }
    }

    private var pullProgress: CGFloat {
        // Map pullOffset 0...80 to progress 0...1
        min(max(pullOffset / 80, 0), 1)
    }
}

private struct OwlRefreshView: View {
    var progress: CGFloat
    var isRefreshing: Bool
    var rotationBounce: Bool

    // Rotation max angle in degrees when pulling
    private let maxPullRotation: Double = 20

    @State private var bounceRotation: Double = 0

    var body: some View {
        Image("owl.refresh")
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
            .frame(height: 60)
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            .scaleEffect(currentScale)
            .rotationEffect(.degrees(currentRotation))
            .animation(isRefreshing ? bounceAnimation : .easeOut(duration: 0.2), value: progress)
            .onAppear {
                if isRefreshing {
                    bounceStart()
                }
            }
            .onChange(of: isRefreshing) { newValue in
                if newValue {
                    bounceStart()
                }
            }
    }

    private var currentScale: CGFloat {
        if isRefreshing {
            1.0
        } else {
            // Scale from 0.6 to 1.2 based on progress
            0.6 + 0.6 * progress
        }
    }

    private var currentRotation: Double {
        if isRefreshing {
            // Bounce rotation oscillates between -10 and 10 degrees
            bounceRotation
        } else {
            // Rotate from 0 to maxPullRotation * progress
            maxPullRotation * Double(progress)
        }
    }

    private var bounceAnimation: Animation {
        Animation.easeInOut(duration: 0.7).repeatForever(autoreverses: true)
    }

    private func bounceStart() {
        withAnimation(bounceAnimation) {
            bounceRotation = 10
        }
    }
}

#Preview("Owl Refresh Demo") {
    if #available(iOS 17.0, *) {
        OwlRefreshContainer(onRefresh: { try? await Task.sleep(nanoseconds: 500_000_000) }) {
            List(0..<10, id: \.self) { i in Text("Row \(i)") }
        }
    } else {
        Text("Preview requires iOS 17+")
    }
}
