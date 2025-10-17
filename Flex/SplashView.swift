import SwiftUI

public struct SplashView: View {
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0.8
    @State private var rotation: Double = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            (Theme.bg ?? Color.black.opacity(0.95))
                .ignoresSafeArea()
            
            Image(systemName: "infinity")
                .font(.system(size: 96, weight: .bold))
                .foregroundColor(Theme.accent ?? .white)
                .scaleEffect(scale)
                .opacity(opacity)
                .rotationEffect(.degrees(rotation))
                .shadow(color: (Theme.accent ?? .white).opacity(0.6), radius: 10, x: 0, y: 0)
                .accessibilityLabel("Loading")
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        scale = 1.05
                        opacity = 1.0
                    }
                    withAnimation(Animation.linear(duration: 4).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
