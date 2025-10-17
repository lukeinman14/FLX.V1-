import SwiftUI

struct EnhancedStockChartView: View {
    let symbol: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var api = StockAPIService.shared
    @State private var selectedTimeframe: ChartTimeframe = .oneDay
    @State private var chartType: ChartDisplayType = .candlestick

    // Interactive chart state
    @State private var selectedDataPoint: ChartPoint?
    @State private var dragLocation: CGPoint?

    enum ChartDisplayType: String, CaseIterable {
        case candlestick = "Candle"
        case line = "Line"
    }

    var stockData: StockData? {
        api.stockCache[symbol]
    }

    var news: [NewsArticle] {
        api.newsCache[symbol] ?? []
    }

    // Calculate change based on selected timeframe
    var timeframeChange: (price: Double, change: Double, changePercent: Double) {
        guard let data = stockData, !data.chartData.isEmpty else {
            return (0, 0, 0)
        }

        let relevantData = Array(data.chartData.suffix(selectedTimeframe.dataPoints))
        guard let firstPoint = relevantData.first,
              let lastPoint = relevantData.last else {
            return (data.price, data.change, data.changePercent)
        }

        let change = lastPoint.close - firstPoint.close
        let changePercent = (change / firstPoint.close) * 100

        return (lastPoint.close, change, changePercent)
    }

    // Get full name for symbol
    var fullName: String {
        switch symbol.uppercased() {
        case "NVDA": return "NVIDIA Corporation"
        case "AAPL": return "Apple Inc."
        case "TSLA": return "Tesla, Inc."
        case "MSFT": return "Microsoft Corporation"
        case "GOOGL", "GOOG": return "Alphabet Inc."
        case "AMZN": return "Amazon.com, Inc."
        case "META": return "Meta Platforms, Inc."
        case "BTC", "BITCOIN": return "Bitcoin"
        case "ETH", "ETHEREUM": return "Ethereum"
        case "SOL", "SOLANA": return "Solana"
        default: return symbol.uppercased()
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with stock info
                    if let data = stockData {
                        headerSection(data: data)
                    }

                    // Timeframe and chart type selector
                    controlsSection

                    // Chart
                    if let data = stockData {
                        chartSection(data: data)
                            .frame(height: 350)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    } else {
                        loadingSection
                    }

                    // News Section
                    newsSection
                }
            }
            .background(Theme.bg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.accentMuted)
                }
            }
            .task {
                await api.fetchStockData(symbol: symbol)
                await api.fetchNews(symbol: symbol)
                // Start auto-refresh for live updates
                api.startAutoRefresh(for: symbol)
            }
            .onDisappear {
                // Stop auto-refresh when view is dismissed
                api.stopAutoRefresh(for: symbol)
            }
        }
    }

    private func headerSection(data: StockData) -> some View {
        let change = timeframeChange

        return VStack(alignment: .leading, spacing: 12) {
            // Full name and symbol
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(fullName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)

                    // Live indicator with pulsing animation
                    let isLive = api.isLiveData[symbol.uppercased()] ?? false
                    LiveIndicator(isLive: isLive)
                }

                Text("$\(symbol.uppercased())")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.textSecondary)
            }

            // Price
            Text("$\(change.price, specifier: "%.2f")")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            // Change for selected timeframe
            HStack(spacing: 8) {
                Text("\(change.change >= 0 ? "+" : "")\(change.change, specifier: "%.2f")")
                    .font(.system(size: 18))
                    .foregroundStyle(change.change >= 0 ? .green : .red)

                Text("(\(change.changePercent >= 0 ? "+" : "")\(change.changePercent, specifier: "%.2f")%)")
                    .font(.system(size: 18))
                    .foregroundStyle(change.changePercent >= 0 ? .green : .red)

                Text(selectedTimeframe.displayName)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Timeframe picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ChartTimeframe.allCases) { timeframe in
                        Button(action: { selectedTimeframe = timeframe }) {
                            Text(timeframe.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selectedTimeframe == timeframe ? Theme.bg : Theme.textPrimary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedTimeframe == timeframe ? Theme.accentMuted : Theme.surface)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            // Chart type picker
            Picker("Chart Type", selection: $chartType) {
                ForEach(ChartDisplayType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
    }

    private func chartSection(data: StockData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Selected point info
            if let selectedPoint = selectedDataPoint {
                selectedPointInfo(selectedPoint)
            }

            // Chart with interactive overlay
            ZStack {
                GeometryReader { geometry in
                    ZStack(alignment: .topLeading) {
                        // Chart layer (behind)
                        makeChart(data: data)
                            .allowsHitTesting(false) // Let touches pass through to overlay

                        // Interactive overlay (in front, but mostly transparent)
                        interactiveOverlay(data: data, geometry: geometry)
                    }
                }
                .frame(height: 300)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Theme.divider, lineWidth: 1)
                )
        )
    }

    private func selectedPointInfo(_ point: ChartPoint) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(point.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Price")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.textSecondary)
                    Text("$\(point.close, specifier: "%.2f")")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                }

                if chartType == .candlestick {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("High")
                        .font(.system(size: 10))
                            .foregroundStyle(Theme.textSecondary)
                        Text("$\(point.high, specifier: "%.2f")")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.green)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Low")
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.textSecondary)
                        Text("$\(point.low, specifier: "%.2f")")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.bg)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.accentMuted.opacity(0.3), lineWidth: 1)
                )
        )
        .transition(.opacity)
    }

    @ViewBuilder
    private func makeChart(data: StockData) -> some View {
        GeometryReader { geometry in
            let chartData = Array(data.chartData.suffix(selectedTimeframe.dataPoints))

            if !chartData.isEmpty {
                // Add padding to min/max to prevent clipping at edges
                let rawMinPrice = chartData.map(\.close).min() ?? 0
                let rawMaxPrice = chartData.map(\.close).max() ?? 1
                let padding = (rawMaxPrice - rawMinPrice) * 0.1 // 10% padding
                let minPrice = rawMinPrice - padding
                let maxPrice = rawMaxPrice + padding
                let priceRange = maxPrice - minPrice

                ZStack {
                    // Grid lines
                    drawGridLines(geometry: geometry, minPrice: minPrice, maxPrice: maxPrice)

                    // Chart line or candlesticks with proper bounds
                    let chartGeometry = CGRect(x: 10, y: 0, width: geometry.size.width - 50, height: geometry.size.height)

                    if chartType == .line {
                        drawLineChart(chartData: chartData, geometry: chartGeometry, minPrice: minPrice, priceRange: priceRange, change: data.change)
                    } else {
                        drawCandlestickChart(chartData: chartData, geometry: chartGeometry, minPrice: minPrice, priceRange: priceRange)
                    }

                    // Price labels
                    drawPriceLabels(geometry: geometry, minPrice: minPrice, maxPrice: maxPrice)
                }
            }
        }
        .frame(height: 300)
    }

    private func drawGridLines(geometry: GeometryProxy, minPrice: Double, maxPrice: Double) -> some View {
        Path { path in
            // Horizontal grid lines
            for i in 0...4 {
                let y = geometry.size.height * CGFloat(i) / 4
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y))
            }
        }
        .stroke(Theme.divider.opacity(0.3), lineWidth: 0.5)
    }

    private func drawPriceLabels(geometry: GeometryProxy, minPrice: Double, maxPrice: Double) -> some View {
        ZStack {
            ForEach(0...4, id: \.self) { i in
                let price = minPrice + (maxPrice - minPrice) * Double(4 - i) / 4
                let y = geometry.size.height * CGFloat(i) / 4

                Text("$\(price, specifier: "%.0f")")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)
                    .position(x: geometry.size.width - 30, y: y)
            }
        }
    }

    private func drawLineChart(chartData: [ChartPoint], geometry: CGRect, minPrice: Double, priceRange: Double, change: Double) -> some View {
        ZStack {
            // Gradient area
            Path { path in
                let points = chartData.enumerated().map { index, point in
                    let x = geometry.minX + (CGFloat(index) / CGFloat(chartData.count - 1) * geometry.width)
                    let yRatio = (point.close - minPrice) / priceRange
                    let y = geometry.maxY - (CGFloat(yRatio) * geometry.height)
                    return CGPoint(x: x, y: y)
                }

                if let first = points.first {
                    path.move(to: CGPoint(x: first.x, y: geometry.maxY))
                    path.addLine(to: first)

                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }

                    path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: geometry.maxY))
                    path.closeSubpath()
                }
            }
            .fill(
                LinearGradient(
                    colors: [
                        (change >= 0 ? Color.green : Color.red).opacity(0.4),
                        (change >= 0 ? Color.green : Color.red).opacity(0.2),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Line
            Path { path in
                let points = chartData.enumerated().map { index, point in
                    let x = geometry.minX + (CGFloat(index) / CGFloat(chartData.count - 1) * geometry.width)
                    let yRatio = (point.close - minPrice) / priceRange
                    let y = geometry.maxY - (CGFloat(yRatio) * geometry.height)
                    return CGPoint(x: x, y: y)
                }

                if let first = points.first {
                    path.move(to: first)

                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
            }
            .stroke(change >= 0 ? Color.green : Color.red, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
    }

    private func drawCandlestickChart(chartData: [ChartPoint], geometry: CGRect, minPrice: Double, priceRange: Double) -> some View {
        ZStack {
            ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                let x = geometry.minX + (CGFloat(index) / CGFloat(chartData.count - 1) * geometry.width)
                let candleWidth: CGFloat = max(5, min(10, geometry.width / CGFloat(chartData.count) * 0.8))

                let openY = geometry.maxY - (CGFloat((point.open - minPrice) / priceRange) * geometry.height)
                let closeY = geometry.maxY - (CGFloat((point.close - minPrice) / priceRange) * geometry.height)
                let highY = geometry.maxY - (CGFloat((point.high - minPrice) / priceRange) * geometry.height)
                let lowY = geometry.maxY - (CGFloat((point.low - minPrice) / priceRange) * geometry.height)

                let isGreen = point.close >= point.open
                let color = isGreen ? Color.green : Color.red

                ZStack {
                    // Wicks
                    Path { path in
                        path.move(to: CGPoint(x: x, y: highY))
                        path.addLine(to: CGPoint(x: x, y: lowY))
                    }
                    .stroke(color, lineWidth: 2)

                    // Body
                    Rectangle()
                        .fill(color)
                        .frame(width: candleWidth, height: max(1, abs(closeY - openY)))
                        .position(x: x, y: (openY + closeY) / 2)
                }
            }
        }
    }

    // Interactive overlay with touch tracking
    private func interactiveOverlay(data: StockData, geometry: GeometryProxy) -> some View {
        let chartData = Array(data.chartData.suffix(selectedTimeframe.dataPoints))
        guard !chartData.isEmpty else { return AnyView(EmptyView()) }

        // Match the padding from makeChart
        let rawMinPrice = chartData.map(\.close).min() ?? 0
        let rawMaxPrice = chartData.map(\.close).max() ?? 1
        let padding = (rawMaxPrice - rawMinPrice) * 0.1
        let minPrice = rawMinPrice - padding
        let maxPrice = rawMaxPrice + padding
        let priceRange = maxPrice - minPrice

        // Match the chart geometry bounds
        let chartBounds = CGRect(x: 10, y: 0, width: geometry.size.width - 50, height: geometry.size.height)

        return AnyView(
            ZStack {
                // Transparent overlay for gesture detection
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value.location, chartData: chartData, chartBounds: chartBounds, minPrice: minPrice, maxPrice: maxPrice, priceRange: priceRange)
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.2)) {
                                    selectedDataPoint = nil
                                    dragLocation = nil
                                }
                            }
                    )

                // Crosshair and dot if dragging
                if let location = dragLocation, let selectedPoint = selectedDataPoint {
                    // Vertical line
                    Path { path in
                        path.move(to: CGPoint(x: location.x, y: 0))
                        path.addLine(to: CGPoint(x: location.x, y: geometry.size.height))
                    }
                    .stroke(Theme.accentMuted.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))

                    // Horizontal line
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: location.y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: location.y))
                    }
                    .stroke(Theme.accentMuted.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5, 5]))

                    // Dot on the line
                    Circle()
                        .fill(Theme.accentMuted)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        )
                        .position(location)

                    // Price label
                    Text("$\(selectedPoint.close, specifier: "%.2f")")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Theme.accentMuted)
                        )
                        .position(x: location.x, y: max(20, min(geometry.size.height - 20, location.y - 30)))
                }
            }
        )
    }

    private func handleDrag(_ location: CGPoint, chartData: [ChartPoint], chartBounds: CGRect, minPrice: Double, maxPrice: Double, priceRange: Double) {
        // Clamp location to chart bounds
        guard location.x >= chartBounds.minX && location.x <= chartBounds.maxX else { return }

        // Calculate which data point is closest to the touch location
        let xRatio = (location.x - chartBounds.minX) / chartBounds.width
        let index = Int(xRatio * CGFloat(chartData.count - 1))

        guard index >= 0 && index < chartData.count else { return }

        let selectedPoint = chartData[index]

        // Calculate the y position for the selected point's price
        let yRatio = (selectedPoint.close - minPrice) / priceRange
        let yPosition = chartBounds.maxY - (CGFloat(yRatio) * chartBounds.height)

        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
            self.selectedDataPoint = selectedPoint
            self.dragLocation = CGPoint(
                x: chartBounds.minX + (CGFloat(index) / CGFloat(chartData.count - 1) * chartBounds.width),
                y: yPosition
            )
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(Theme.accentMuted)
            Text("Loading chart data...")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(height: 350)
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Related News")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 16)
                .padding(.top, 24)

            if news.isEmpty {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Theme.accentMuted)
                    Text("Loading news...")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(news) { article in
                    NewsCard(article: article)
                }
            }
        }
        .padding(.bottom, 32)
    }
}

// MARK: - Live Indicator Component
struct LiveIndicator: View {
    let isLive: Bool
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 4) {
            ZStack {
                // Pulsing outer ring (only for live)
                if isLive {
                    Circle()
                        .fill(Color.green.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(isPulsing ? 1.8 : 1.0)
                        .opacity(isPulsing ? 0 : 1)
                }

                // Inner dot
                Circle()
                    .fill(isLive ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
            }

            Text(isLive ? "LIVE" : "MOCK")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(isLive ? .green : .red)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill((isLive ? Color.green : Color.red).opacity(0.15))
        )
        .onAppear {
            if isLive {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    isPulsing = true
                }
            }
        }
    }
}

// MARK: - News Card Component
struct NewsCard: View {
    let article: NewsArticle

    var body: some View {
        Link(destination: URL(string: article.url)!) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with source and time
                HStack {
                    Text(article.source)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.accentMuted)

                    Spacer()

                    Text(article.publishedAt.timeAgo())
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                // Headline
                Text(article.headline)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                // Summary
                Text(article.summary)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)

                // Read more indicator
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Read more")
                            .font(.system(size: 12, weight: .medium))
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(Theme.accentMuted)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Theme.divider, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    EnhancedStockChartView(symbol: "NVDA")
        .preferredColorScheme(.dark)
}
