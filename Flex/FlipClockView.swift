import SwiftUI

struct FlipClockView: View {
    let endDate: Date
    @State private var timeRemaining: (days: Int, hours: Int, minutes: Int)
    @State private var timer: Timer?
    @Environment(\.colorScheme) private var colorScheme

    init(endDate: Date) {
        self.endDate = endDate
        // Calculate initial time remaining
        let now = Date()
        let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: endDate)
        _timeRemaining = State(initialValue: (
            days: max(0, difference.day ?? 0),
            hours: max(0, difference.hour ?? 0),
            minutes: max(0, difference.minute ?? 0)
        ))
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("Season ends in:")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.6))

            HStack(spacing: 10) {
                FlipDigitPair(value: timeRemaining.days, label: "DAYS")

                Text(":")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accentMuted)

                FlipDigitPair(value: timeRemaining.hours, label: "HOURS")

                Text(":")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accentMuted)

                FlipDigitPair(value: timeRemaining.minutes, label: "MINS")
            }
        }
        .onAppear {
            updateTime()
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
                updateTime()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func updateTime() {
        let now = Date()
        let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: endDate)

        withAnimation(.easeInOut(duration: 0.4)) {
            timeRemaining = (
                days: max(0, difference.day ?? 0),
                hours: max(0, difference.hour ?? 0),
                minutes: max(0, difference.minute ?? 0)
            )
        }
    }
}

struct FlipDigitPair: View {
    let value: Int
    let label: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                FlipDigit(digit: value / 10)
                FlipDigit(digit: value % 10)
            }

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(colorScheme == .dark ? Theme.textSecondary : Color.white.opacity(0.5))
        }
    }
}

struct FlipDigit: View {
    let digit: Int
    @State private var previousDigit: Int
    @State private var isFlipping = false
    @Environment(\.colorScheme) private var colorScheme

    init(digit: Int) {
        self.digit = digit
        _previousDigit = State(initialValue: digit)
    }

    var body: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.3),
                            Color.white.opacity(colorScheme == .dark ? 0.04 : 0.2)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 40, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.3), lineWidth: 1)
                )

            // Middle divider line
            Rectangle()
                .fill(colorScheme == .dark ? Theme.bg : Color.black.opacity(0.1))
                .frame(height: 1)

            // Flip animation
            if isFlipping {
                VStack(spacing: 0) {
                    // Top half - previous digit
                    FlipHalf(digit: previousDigit, isTop: true)
                        .rotation3DEffect(
                            .degrees(-90),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .bottom,
                            perspective: 0.5
                        )
                        .opacity(0)

                    // Bottom half - new digit
                    FlipHalf(digit: digit, isTop: false)
                        .rotation3DEffect(
                            .degrees(90),
                            axis: (x: 1, y: 0, z: 0),
                            anchor: .top,
                            perspective: 0.5
                        )
                        .animation(.easeOut(duration: 0.3), value: digit)
                }
            } else {
                VStack(spacing: 0) {
                    FlipHalf(digit: digit, isTop: true)
                    FlipHalf(digit: digit, isTop: false)
                }
            }
        }
        .frame(width: 40, height: 54)
        .onChange(of: digit) { oldValue, newValue in
            if oldValue != newValue {
                previousDigit = oldValue
                withAnimation(.easeInOut(duration: 0.6)) {
                    isFlipping = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        isFlipping = false
                    }
                }
            }
        }
    }
}

struct FlipHalf: View {
    let digit: Int
    let isTop: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)

            Text("\(digit)")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(colorScheme == .dark ? Theme.textPrimary : .white)
                .offset(y: isTop ? 13 : -13)
        }
        .frame(width: 40, height: 27)
        .clipped()
    }
}
