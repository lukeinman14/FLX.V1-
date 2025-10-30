import SwiftUI
import Charts

struct NetWorthChart: View {
    let currentNetWorth: Double
    let nextTierThreshold: Double
    let nextTierName: String

    @State private var selectedTimeframe: Timeframe = .max
    @State private var animationProgress: CGFloat = 0
    @State private var touchLocation: CGPoint?
    @State private var selectedDataPoint: (value: Double, date: String)?
    @Environment(\.colorScheme) private var colorScheme

    enum Timeframe: String, CaseIterable {
        case oneMonth = "1M"
        case ytd = "YTD"
        case oneYear = "1Y"
        case max = "MAX"
    }

    var amountNeeded: Double {
        max(0, nextTierThreshold - currentNetWorth)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with current net worth
            VStack(alignment: .leading, spacing: 4) {
                Text("Overview")
                    .font(Theme.headingFont())
                    .foregroundStyle(Theme.textPrimary)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    // Show selected value if touching, otherwise current
                    Text(formatCurrency(selectedDataPoint?.value ?? currentNetWorth))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .animation(.easeInOut(duration: 0.2), value: selectedDataPoint?.value)

                    Spacer()

                    // Amount needed to reach next tier with 3D gold finish
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(formatCurrency(amountNeeded)) to unlock")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.textSecondary)

                        // 3D Metallic "Gold Status" text
                        Text("\(nextTierName) Status")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.98, green: 0.85, blue: 0.35).opacity(0.8),
                                        Color(red: 0.98, green: 0.85, blue: 0.35),
                                        Color(red: 0.98, green: 0.85, blue: 0.35).opacity(0.6),
                                        Color(red: 0.98, green: 0.85, blue: 0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(red: 0.98, green: 0.85, blue: 0.35).opacity(0.5), radius: 1, x: 0, y: 0.5)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .overlay(
                                Text("\(nextTierName) Status")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .white.opacity(0.6),
                                                .clear,
                                                .clear,
                                                .clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .center
                                        )
                                    )
                                    .blendMode(.overlay)
                            )
                    }
                }

                // Change indicator or selected date
                if let selected = selectedDataPoint {
                    Text(selected.date)
                        .font(Theme.smallFont())
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("+$4,500")
                            .font(Theme.smallFont().weight(.medium))
                        Text("Past Week")
                            .font(Theme.smallFont())
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .foregroundStyle(Color.green)
                }
            }

            // Chart
            ZStack(alignment: .topTrailing) {
                chartView
                    .frame(height: 180)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                touchLocation = value.location
                                updateSelectedDataPoint(at: value.location)
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    touchLocation = nil
                                    selectedDataPoint = nil
                                }
                            }
                    )

                // Next tier marker line
                GeometryReader { geo in
                    let markerY = calculateMarkerY(geo: geo)

                    HStack(spacing: 4) {
                        Spacer()

                        // Dashed line
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: markerY))
                            path.addLine(to: CGPoint(x: geo.size.width - 50, y: markerY))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(Theme.accentMuted.opacity(0.5))

                        // Marker dot
                        Circle()
                            .fill(Theme.accentMuted)
                            .frame(width: 6, height: 6)
                            .offset(x: -53)
                    }

                    // Touch indicator - only show when actively touching
                    if let touch = touchLocation, selectedDataPoint != nil {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color.green.opacity(0.3), lineWidth: 8)
                            )
                            .position(getNearestPointOnChart(at: touch, in: geo.size))
                    }
                }
                .allowsHitTesting(false)
            }

            // Timeframe selector
            HStack(spacing: 0) {
                ForEach(Timeframe.allCases, id: \.self) { timeframe in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTimeframe = timeframe
                        }
                    } label: {
                        Text(timeframe.rawValue)
                            .font(.system(size: 13, weight: selectedTimeframe == timeframe ? .semibold : .regular))
                            .foregroundStyle(selectedTimeframe == timeframe ? Theme.accentMuted : Theme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedTimeframe == timeframe ? Theme.accentMuted.opacity(0.15) : Color.clear)
                            )
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .background(liquidGlassBackground())
        .padding(.horizontal, 16)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }

    private var chartView: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let data = generateChartData()
                let path = createChartPath(data: data, size: size)

                // Draw gradient fill
                var gradientPath = path
                gradientPath.addLine(to: CGPoint(x: size.width, y: size.height))
                gradientPath.addLine(to: CGPoint(x: 0, y: size.height))
                gradientPath.closeSubpath()

                context.fill(
                    Path(gradientPath.cgPath),
                    with: .linearGradient(
                        Gradient(colors: [
                            Color.green.opacity(0.3),
                            Color.green.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: CGPoint(x: 0, y: 0),
                        endPoint: CGPoint(x: 0, y: size.height)
                    )
                )

                // Draw line
                context.stroke(
                    path,
                    with: .color(Color.green),
                    lineWidth: 2.5
                )
            }
        }
    }

    private func generateChartData() -> [Double] {
        let points: Int
        let endValue = currentNetWorth

        switch selectedTimeframe {
        case .oneMonth:
            points = 30
        case .ytd:
            points = 90
        case .oneYear:
            points = 52
        case .max:
            points = 100
        }

        var data: [Double] = []

        // Since user just connected accounts, show a quick spike to 82k
        // Start from near-zero and spike up dramatically
        for i in 0...points {
            let progress = Double(i) / Double(points)

            if progress < 0.05 {
                // Start very low (near zero)
                data.append(0)
            } else {
                // Sharp exponential growth to current value
                let growthProgress = (progress - 0.05) / 0.95
                let value = endValue * pow(growthProgress, 0.3) // Exponential curve
                data.append(value)
            }
        }

        // Ensure last point is exactly the current net worth
        if !data.isEmpty {
            data[data.count - 1] = endValue
        }

        return data
    }

    private func getDateForDataPoint(index: Int, totalPoints: Int) -> String {
        let calendar = Calendar.current
        let now = Date()

        let daysBack: Int
        switch selectedTimeframe {
        case .oneMonth:
            daysBack = 30
        case .ytd:
            daysBack = calendar.dateComponents([.day], from: calendar.date(from: calendar.dateComponents([.year], from: now))!, to: now).day ?? 90
        case .oneYear:
            daysBack = 365
        case .max:
            daysBack = 365 // Assuming max is 1 year for now
        }

        let daysPerPoint = Double(daysBack) / Double(totalPoints - 1)
        let daysAgo = Int(Double(totalPoints - 1 - index) * daysPerPoint)

        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: now) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func updateSelectedDataPoint(at location: CGPoint) {
        let data = generateChartData()
        guard !data.isEmpty else { return }

        // Calculate which data point is closest to touch
        let totalWidth: CGFloat = 350 // Approximate chart width
        let xStep = totalWidth / CGFloat(data.count - 1)
        let index = min(max(0, Int(round(location.x / xStep))), data.count - 1)

        selectedDataPoint = (
            value: data[index],
            date: getDateForDataPoint(index: index, totalPoints: data.count)
        )
    }

    private func getNearestPointOnChart(at location: CGPoint, in size: CGSize) -> CGPoint {
        let data = generateChartData()
        guard !data.isEmpty else { return .zero }

        let maxValue = max(data.max() ?? currentNetWorth, nextTierThreshold)
        let minValue = 0.0
        let range = maxValue - minValue

        let xStep = size.width / CGFloat(data.count - 1)
        let index = min(max(0, Int(round(location.x / xStep))), data.count - 1)

        let x = CGFloat(index) * xStep
        let normalizedValue = (data[index] - minValue) / range
        let y = size.height - (CGFloat(normalizedValue) * size.height * 0.85)

        return CGPoint(x: x, y: y)
    }

    private func createChartPath(data: [Double], size: CGSize) -> Path {
        var path = Path()

        guard !data.isEmpty else { return path }

        let maxValue = max(data.max() ?? currentNetWorth, nextTierThreshold)
        let minValue = 0.0
        let range = maxValue - minValue

        let xStep = size.width / CGFloat(data.count - 1)

        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * xStep
            let normalizedValue = (value - minValue) / range
            let y = size.height - (CGFloat(normalizedValue) * size.height * 0.85) // Leave 15% padding at top

            // Apply animation progress
            let animatedX = x * animationProgress

            if index == 0 {
                path.move(to: CGPoint(x: animatedX, y: y))
            } else {
                path.addLine(to: CGPoint(x: animatedX, y: y))
            }
        }

        return path
    }

    private func calculateMarkerY(geo: GeometryProxy) -> CGFloat {
        let data = generateChartData()
        let maxValue = max(data.max() ?? currentNetWorth, nextTierThreshold)
        let minValue = 0.0
        let range = maxValue - minValue

        let normalizedThreshold = (nextTierThreshold - minValue) / range
        return geo.size.height - (CGFloat(normalizedThreshold) * geo.size.height * 0.85)
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    @ViewBuilder
    private func liquidGlassBackground() -> some View {
        if colorScheme == .dark {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 0.5
                        )
                        .blur(radius: 0.5)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .shadow(color: Color.white.opacity(0.05), radius: 2, x: 0, y: -1)
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.72, green: 0.72, blue: 0.74, opacity: 0.85),
                            Color(red: 0.67, green: 0.67, blue: 0.69, opacity: 0.90),
                            Color(red: 0.64, green: 0.64, blue: 0.66, opacity: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.4))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.7),
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            ),
                            lineWidth: 1
                        )
                        .blur(radius: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .shadow(color: Color.white.opacity(0.4), radius: 1, x: 0, y: -1)
        }
    }
}
