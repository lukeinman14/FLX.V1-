import SwiftUI
import Combine

struct StockNewsItem: Identifiable, Decodable {
    let id: Int
    let title: String
    let body: String
}

@MainActor
final class StockNewsModel: ObservableObject {
    @Published var items: [StockNewsItem] = []
    @Published var isLoading = false

    func fetchDemoNews(for symbol: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let url = URL(string: "https://jsonplaceholder.typicode.com/posts?_limit=5")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([StockNewsItem].self, from: data)
            self.items = decoded
        } catch {
            self.items = []
        }
    }
}

struct StockChatView: View {
    var symbol: String

    enum Timeframe: String, CaseIterable { case oneD = "1D", oneW = "1W", oneM = "1M", oneY = "1Y" }
    @State private var timeframe: Timeframe = .oneW

    @State private var mode: ChartMode = .candles
    enum ChartMode: String, CaseIterable { case line = "Line", candles = "Candles" }
    @State private var selectedEvent: ChartEvent? = nil

    @StateObject private var news = StockNewsModel()
    @State private var newsTimer: Timer? = nil

    struct ChartEvent: Identifiable { let id = UUID(); let index: Int; let title: String }

    struct Msg: Identifiable { let id = UUID(); let text: String; let mine: Bool }
    private var messages: [Msg] {
        [
            .init(text: "What’s your target on \(symbol)?", mine: false),
            .init(text: "Watching 200D MA. Accumulating on dips.", mine: true),
            .init(text: "Earnings next week — expecting volatility.", mine: false),
            .init(text: "Agreed. I’ll trim if we gap up >5%.", mine: true)
        ]
    }
    
    @State private var draft = ""

    private var mockPoints: [Double] {
        switch timeframe {
        case .oneD:
            return generateSeries(count: 48, base: 100, amp: 1.2, noise: 0.4, freq: 3)
        case .oneW:
            return generateSeries(count: 30, base: 100, amp: 3.0, noise: 0.8, freq: 1)
        case .oneM:
            return generateSeries(count: 30, base: 98, amp: 6.0, noise: 1.2, freq: 0.5)
        case .oneY:
            return generateSeries(count: 52, base: 90, amp: 12.0, noise: 2.2, freq: 0.25)
        }
    }
    
    private var currentPointCount: Int {
        switch timeframe { case .oneD: return 48; case .oneW: return 30; case .oneM: return 30; case .oneY: return 52 }
    }

    struct Candle { let open: Double; let high: Double; let low: Double; let close: Double }

    private var mockCandles: [Candle] {
        let pts = mockPoints
        // Build candles from points by grouping pairs
        var arr: [Candle] = []
        var i = 0
        while i < pts.count - 1 {
            let o = pts[i]
            let c = pts[i+1]
            let h = max(o, c) + Double.random(in: 0...1.0)
            let l = min(o, c) - Double.random(in: 0...1.0)
            arr.append(Candle(open: o, high: h, low: l, close: c))
            i += 2
        }
        return arr
    }

    private var mockEvents: [ChartEvent] {
        // Place a couple of events across the series
        let n = currentPointCount
        guard n > 10 else { return [] }
        return [
            ChartEvent(index: n/4, title: "Earnings beat: +5%"),
            ChartEvent(index: (3*n)/5, title: "News: Product launch")
        ]
    }

    private func generateSeries(count: Int, base: Double, amp: Double, noise: Double, freq: Double) -> [Double] {
        (0..<count).map { i in
            let x = Double(i) * freq / 6.0
            return base + sin(x) * amp + Double.random(in: -noise...noise)
        }
    }

    private func movingAverage(_ points: [Double], window: Int) -> [Double] {
        guard window > 1 else { return points }
        var avg: [Double] = []
        for i in 0..<points.count {
            let start = max(0, i - window + 1)
            let slice = points[start...i]
            avg.append(slice.reduce(0, +) / Double(slice.count))
        }
        return avg
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            chart
            newsSection
            Divider().background(Theme.divider)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(messages) { msg in
                        ChatBubble(text: msg.text, isMine: msg.mine)
                    }
                }
                .padding(.top, 8)
            }
            inputBar
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("$\(symbol) Chat")
        #if os(iOS)
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        #endif
        .sheet(item: $selectedEvent) { ev in
            VStack(spacing: 12) {
                Text("Event").font(Theme.headingFont()).foregroundStyle(Theme.accent)
                Text(ev.title).font(Theme.bodyFont()).foregroundStyle(Theme.textPrimary)
                Button("Close") { selectedEvent = nil }
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
            }
            .padding(20)
            .background(Theme.bg)
            .presentationDetents([.fraction(0.25)])
        }
        .task {
            await news.fetchDemoNews(for: symbol)
            newsTimer?.invalidate()
            newsTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
                Task { await news.fetchDemoNews(for: symbol) }
            }
        }
        .onDisappear {
            newsTimer?.invalidate()
            newsTimer = nil
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Text("$\(symbol)")
                .font(Theme.headingFont())
                .foregroundStyle(Theme.accentMuted)
            Spacer()
            Menu(timeframe.rawValue) {
                ForEach(Timeframe.allCases, id: \.self) { tf in Button(tf.rawValue) { timeframe = tf } }
            }
            .font(Theme.smallFont())
            .foregroundStyle(Theme.accentMuted)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
            Menu(mode.rawValue) {
                ForEach(ChartMode.allCases, id: \.self) { m in Button(m.rawValue) { mode = m } }
            }
            .font(Theme.smallFont())
            .foregroundStyle(Theme.accentMuted)
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.bg)
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Price (7d)")
                .font(Theme.smallFont())
                .foregroundStyle(Theme.textSecondary)
                .padding(.horizontal, 16)
            ZStack(alignment: .topLeading) {
                if mode == .line {
                    MockLineChart(points: mockPoints, movingAverage: movingAverage)
                } else {
                    MockCandles(candles: mockCandles)
                }
                EventMarkers(count: currentPointCount, events: mockEvents, tap: { ev in selectedEvent = ev })
            }
            .frame(height: 140)
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
    }

    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("News & Events")
                    .font(Theme.smallFont())
                    .foregroundStyle(Theme.textSecondary)
                if news.isLoading {
                    ProgressView().scaleEffect(0.7).tint(Theme.accentMuted)
                }
                Spacer()
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                ForEach(news.items) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title.capitalized)
                            .font(Theme.bodyFont().weight(.semibold))
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(item.body)
                            .font(Theme.smallFont())
                            .foregroundStyle(Theme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(Theme.surface)
                    .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.divider), alignment: .bottom)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Message $\(symbol)", text: $draft)
                .textFieldStyle(.plain)
                .font(Theme.bodyFont())
                .foregroundStyle(Theme.textPrimary)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(Theme.surface)
                        .overlay(Capsule().stroke(Theme.divider, lineWidth: 1))
                )
            Button { draft.removeAll() } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(Theme.accentMuted)
                    .font(.system(size: 22))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Theme.bg.opacity(0.9).ignoresSafeArea(edges: .bottom))
    }
}

struct MockLineChart: View {
    var points: [Double]
    var movingAverage: (_ points: [Double], _ window: Int) -> [Double]

    var body: some View {
        GeometryReader { geo in
            let minY = points.min() ?? 0
            let maxY = points.max() ?? 1
            let range = max(maxY - minY, 0.001)
            let stepX = geo.size.width / CGFloat(max(points.count - 1, 1))
            let ma = movingAverage(points, max(2, points.count / 10))

            ZStack {
                // Area fill under main line
                Path { path in
                    for (idx, y) in points.enumerated() {
                        let xPos = CGFloat(idx) * stepX
                        let norm = (y - minY) / range
                        let yPos = geo.size.height * (1 - CGFloat(norm))
                        if idx == 0 {
                            path.move(to: CGPoint(x: xPos, y: geo.size.height))
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        } else {
                            path.addLine(to: CGPoint(x: xPos, y: yPos))
                        }
                    }
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(LinearGradient(colors: [Theme.accentMuted.opacity(0.20), .clear], startPoint: .top, endPoint: .bottom))

                // Main price line
                Path { path in
                    for (idx, y) in points.enumerated() {
                        let xPos = CGFloat(idx) * stepX
                        let norm = (y - minY) / range
                        let yPos = geo.size.height * (1 - CGFloat(norm))
                        if idx == 0 { path.move(to: CGPoint(x: xPos, y: yPos)) }
                        else { path.addLine(to: CGPoint(x: xPos, y: yPos)) }
                    }
                }
                .strokedPath(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient(colors: [Theme.accentMuted, Theme.accent], startPoint: .leading, endPoint: .trailing))

                // Moving average line
                Path { path in
                    for (idx, y) in ma.enumerated() {
                        let xPos = CGFloat(idx) * stepX
                        let norm = (y - minY) / range
                        let yPos = geo.size.height * (1 - CGFloat(norm))
                        if idx == 0 { path.move(to: CGPoint(x: xPos, y: yPos)) }
                        else { path.addLine(to: CGPoint(x: xPos, y: yPos)) }
                    }
                }
                .strokedPath(.init(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(Theme.textSecondary)
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.surface)
                    RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1)
                }
            )
        }
    }
}

struct MockCandles: View {
    var candles: [StockChatView.Candle]
    var body: some View {
        GeometryReader { geo in
            let highs = candles.map { $0.high }
            let lows = candles.map { $0.low }
            let minY = lows.min() ?? 0
            let maxY = highs.max() ?? 1
            let range = max(maxY - minY, 0.001)
            let stepX = geo.size.width / CGFloat(max(candles.count - 1, 1))

            ZStack {
                ForEach(Array(candles.enumerated()), id: \.offset) { idx, c in
                    let x = CGFloat(idx) * stepX
                    let up = c.close >= c.open
                    let color: Color = up ? Theme.accentMuted : Color.red.opacity(0.8)
                    let yHigh = geo.size.height * (1 - CGFloat((c.high - minY)/range))
                    let yLow = geo.size.height * (1 - CGFloat((c.low - minY)/range))
                    let yOpen = geo.size.height * (1 - CGFloat((c.open - minY)/range))
                    let yClose = geo.size.height * (1 - CGFloat((c.close - minY)/range))
                    // Wick
                    Path { p in
                        p.move(to: CGPoint(x: x, y: yHigh))
                        p.addLine(to: CGPoint(x: x, y: yLow))
                    }
                    .strokedPath(.init(lineWidth: 1))
                    .foregroundStyle(color)
                    // Body
                    let bodyTop = min(yOpen, yClose)
                    let bodyHeight = max(2, abs(yClose - yOpen))
                    Rectangle()
                        .fill(color)
                        .frame(width: 6, height: bodyHeight)
                        .position(x: x, y: bodyTop + bodyHeight/2)
                }
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Theme.surface)
                    RoundedRectangle(cornerRadius: 10).stroke(Theme.divider, lineWidth: 1)
                }
            )
        }
    }
}

struct EventMarkers: View {
    var count: Int
    var events: [StockChatView.ChartEvent]
    var tap: (StockChatView.ChartEvent) -> Void
    var body: some View {
        GeometryReader { geo in
            let stepX = geo.size.width / CGFloat(max(count - 1, 1))
            ForEach(events) { ev in
                let x = CGFloat(ev.index) * stepX
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 8, height: 8)
                    .position(x: x, y: 8)
                    .onTapGesture { tap(ev) }
                    .overlay(Text("E").font(.system(size: 8, weight: .bold)).foregroundStyle(Theme.bg))
            }
        }
        .sheet(item: Binding(get: { events.first(where: { $0.id == events.first(where: { _ in false })?.id }) }, set: { _ in })) { _ in
            // unused sheet; actual presentation handled in parent via selectedEvent
            EmptyView()
        }
    }
}

struct MiniChartPreview: View {
    let symbol: String
    var body: some View {
        GeometryReader { geo in
            let points = (0..<24).map { i in 100 + sin(Double(i)/4) * 3 + Double.random(in: -0.8...0.8) }
            let minY = points.min() ?? 0
            let maxY = points.max() ?? 1
            let range = max(maxY - minY, 0.001)
            let stepX = geo.size.width / CGFloat(max(points.count - 1, 1))

            ZStack {
                Path { path in
                    for (i, y) in points.enumerated() {
                        let x = CGFloat(i) * stepX
                        let norm = (y - minY)/range
                        let yy = geo.size.height * (1 - CGFloat(norm))
                        if i == 0 { path.move(to: CGPoint(x: x, y: yy)) } else { path.addLine(to: CGPoint(x: x, y: yy)) }
                    }
                }
                .strokedPath(.init(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(LinearGradient(colors: [Theme.accentMuted, Theme.accent], startPoint: .leading, endPoint: .trailing))
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Theme.surface)
                    RoundedRectangle(cornerRadius: 8).stroke(Theme.divider, lineWidth: 1)
                }
            )
        }
        .frame(height: 40)
    }
}

#Preview {
    NavigationStack { StockChatView(symbol: "AAPL") }
        .preferredColorScheme(.dark)
}

