import Foundation
import Foundation
import SwiftUI
import Combine

// MARK: - App Models
struct StockData {
    let symbol: String
    let price: Double
    let change: Double
    let changePercent: Double
    let chartData: [ChartPoint]
    let lastUpdated: Date
}

struct ChartPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let price: Double
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}

enum ChartTimeframe: String, CaseIterable, Identifiable {
    case oneHour = "1H"
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case oneYear = "1Y"
    case fiveYears = "5Y"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var apiInterval: String {
        switch self {
        case .oneHour: return "5min"
        case .oneDay: return "15min"
        case .oneWeek: return "60min"
        case .oneMonth: return "daily"
        case .oneYear: return "weekly"
        case .fiveYears: return "monthly"
        }
    }

    var dataPoints: Int {
        switch self {
        case .oneHour: return 12 // 12 * 5min = 1 hour
        case .oneDay: return 32 // 32 * 15min = 8 hours (trading day)
        case .oneWeek: return 40 // 40 * 60min = ~1 week
        case .oneMonth: return 30 // 30 days
        case .oneYear: return 52 // 52 weeks
        case .fiveYears: return 60 // 60 months
        }
    }
}

// MARK: - News Models
struct NewsArticle: Identifiable, Codable {
    let id: String
    let headline: String
    let source: String
    let url: String
    let summary: String
    let imageURL: String?
    let publishedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, headline, source, url, summary
        case imageURL = "image"
        case publishedAt = "datetime"
    }
}

// MARK: - Finnhub API Models
struct FinnhubQuote: Codable {
    let c: Double  // Current price
    let h: Double  // High price of the day
    let l: Double  // Low price of the day
    let o: Double  // Open price of the day
    let pc: Double // Previous close price
    let t: Int     // Timestamp
}

struct FinnhubCandle: Codable {
    let c: [Double]  // Close prices
    let h: [Double]  // High prices
    let l: [Double]  // Low prices
    let o: [Double]  // Open prices
    let s: String    // Status
    let t: [Int]     // Timestamps
    let v: [Double]  // Volume
}

struct FinnhubNews: Codable {
    let category: String
    let datetime: Int
    let headline: String
    let id: Int
    let image: String
    let related: String
    let source: String
    let summary: String
    let url: String
}

// MARK: - Stock API Service
@MainActor
class StockAPIService: ObservableObject {
    static let shared = StockAPIService()

    // Get your free API key from: https://finnhub.io/dashboard
    // Free tier: 60 API calls/minute
    private let apiKey = "d3o7lgpr01qmj8305gr0d3o7lgpr01qmj8305grg"
    private let baseURL = "https://finnhub.io/api/v1"

    // CoinGecko API key for crypto data
    private let coinGeckoAPIKey = "CG-71QxqYnjK8T6BwpnCJcgM4jF"
    
    @Published var stockCache: [String: StockData] = [:]
    @Published var isLoading: Set<String> = []
    @Published var newsCache: [String: [NewsArticle]] = [:]
    @Published var isLiveData: [String: Bool] = [:]

    // Auto-refresh settings
    private var refreshTimers: [String: Timer] = [:]
    private let autoRefreshInterval: TimeInterval = 2 // Refresh every 2 seconds for fastest live updates

    private func logStockResult(_ symbol: String, quote: FinnhubQuote?, candles: FinnhubCandle?, usedMock: Bool) {
        if usedMock {
            print("[StockAPIService] Using MOCK data for \(symbol)")
        } else {
            if let q = quote {
                print("[StockAPIService] Finnhub QUOTE for \(symbol): c=\(q.c), o=\(q.o), h=\(q.h), l=\(q.l), pc=\(q.pc), t=\(q.t)")
            }
            if let c = candles {
                let count = c.c.count
                print("[StockAPIService] Finnhub CANDLES for \(symbol): status=\(c.s), points=\(count)")
            }
        }
    }

    private init() {}

    private func isCrypto(_ symbol: String) -> Bool {
        let s = symbol.uppercased()
        return s == "BTC" || s == "ETH" || s == "SOL" || s == "DOGE"
    }

    private func finnhubCryptoSymbol(for symbol: String) -> String {
        // Map app-level symbols to Finnhub crypto symbols (exchange:pair)
        // Default to BINANCE USDT pairs
        switch symbol.uppercased() {
        case "BTC": return "BINANCE:BTCUSDT"
        case "ETH": return "BINANCE:ETHUSDT"
        case "SOL": return "BINANCE:SOLUSDT"
        case "DOGE": return "BINANCE:DOGEUSDT"
        default: return "BINANCE:BTCUSDT"
        }
    }
    
    private func finnhubCryptoCandidates(for symbol: String) -> [String] {
        let base = symbol.uppercased()
        switch base {
        case "BTC":
            return ["BINANCE:BTCUSDT", "COINBASE:BTC-USD", "KRAKEN:XBTUSD"]
        case "ETH":
            return ["BINANCE:ETHUSDT", "COINBASE:ETH-USD", "KRAKEN:ETHUSD"]
        default:
            return [finnhubCryptoSymbol(for: base)]
        }
    }
    
    private func fetchData(from url: URL) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        if !(200...299).contains(http.statusCode) {
            let snippet = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[StockAPIService] HTTP \(http.statusCode) for URL: \(url.absoluteString) body: \(snippet.prefix(300))")
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }

    // MARK: - CoinGecko API Implementation
    private func coinGeckoId(for symbol: String) -> String {
        switch symbol.uppercased() {
        case "BTC": return "bitcoin"
        case "ETH": return "ethereum"
        case "SOL": return "solana"
        case "DOGE": return "dogecoin"
        default: return "bitcoin"
        }
    }

    private func fetchCryptoFromCoinGecko(symbol: String) async throws -> StockData {
        let coinId = coinGeckoId(for: symbol)
        print("[StockAPIService] 🌐 Fetching CoinGecko data for \(symbol) (coinId: \(coinId))...")

        // Fetch current price and 24h data - API key as query parameter
        let priceURL = "https://api.coingecko.com/api/v3/simple/price?ids=\(coinId)&vs_currencies=usd&include_24hr_change=true&include_24hr_vol=true&x_cg_demo_api_key=\(coinGeckoAPIKey)"
        guard let url = URL(string: priceURL) else {
            print("[StockAPIService] ❌ Invalid price URL")
            throw URLError(.badURL)
        }

        let (priceData, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            print("[StockAPIService] 📡 CoinGecko price API response: HTTP \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: priceData, encoding: .utf8) {
            print("[StockAPIService] 📄 Price response: \(jsonString)")
        }

        print("[StockAPIService] ✅ CoinGecko price data fetched for \(symbol)")

        struct CoinGeckoPrice: Codable {
            let usd: Double
            let usd_24h_change: Double?
        }

        let decoder = JSONDecoder()
        let priceResponse = try decoder.decode([String: CoinGeckoPrice].self, from: priceData)
        guard let coinPrice = priceResponse[coinId] else {
            throw URLError(.cannotParseResponse)
        }

        // Fetch market chart data (last 7 days) - API key as query parameter
        // Note: Demo plan automatically provides hourly data for 2-90 days, no interval parameter needed
        let chartURL = "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart?vs_currency=usd&days=7&x_cg_demo_api_key=\(coinGeckoAPIKey)"
        guard let chartURLObj = URL(string: chartURL) else { throw URLError(.badURL) }

        let (chartData, _) = try await URLSession.shared.data(from: chartURLObj)
        print("[StockAPIService] ✅ CoinGecko chart data fetched for \(symbol)")

        if let jsonString = String(data: chartData, encoding: .utf8) {
            NSLog("📊 [StockAPIService] Chart response: \(jsonString.prefix(200))...")
        }

        struct CoinGeckoChart: Codable {
            let prices: [[Double]]  // [[timestamp_ms, price], ...]
        }

        let chartResponse = try decoder.decode(CoinGeckoChart.self, from: chartData)
        NSLog("✅ [StockAPIService] Parsed \(chartResponse.prices.count) price points for \(symbol)")

        // Convert to ChartPoint array
        var chartPoints: [ChartPoint] = []
        for pricePoint in chartResponse.prices {
            guard pricePoint.count >= 2 else { continue }
            let timestamp = Date(timeIntervalSince1970: pricePoint[0] / 1000) // Convert ms to seconds
            let price = pricePoint[1]

            // Create OHLC data (CoinGecko only provides price, so we approximate)
            chartPoints.append(ChartPoint(
                timestamp: timestamp,
                price: price,
                open: price,
                high: price * 1.005,  // Approximate high
                low: price * 0.995,   // Approximate low
                close: price,
                volume: 0  // CoinGecko doesn't provide volume in this endpoint
            ))
        }

        let currentPrice = coinPrice.usd
        let change24h = coinPrice.usd_24h_change ?? 0.0
        let previousClose = currentPrice / (1 + change24h / 100)
        let change = currentPrice - previousClose

        print("[StockAPIService] 🚀 LIVE DATA for \(symbol): $\(currentPrice) (\(change24h > 0 ? "+" : "")\(String(format: "%.2f", change24h))%) - \(chartPoints.count) data points")

        return StockData(
            symbol: symbol.uppercased(),
            price: currentPrice,
            change: change,
            changePercent: change24h,
            chartData: chartPoints,
            lastUpdated: Date()
        )
    }

    // MARK: - Auto-Refresh Management
    func startAutoRefresh(for symbol: String) {
        // Cancel existing timer if any
        stopAutoRefresh(for: symbol)

        print("[StockAPIService] ▶️ Starting auto-refresh for \(symbol) every \(Int(autoRefreshInterval))s")

        // Create timer on main thread
        let timer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshStockData(symbol: symbol)
            }
        }
        refreshTimers[symbol] = timer
    }

    func stopAutoRefresh(for symbol: String) {
        refreshTimers[symbol]?.invalidate()
        refreshTimers[symbol] = nil
        print("[StockAPIService] ⏸️ Stopped auto-refresh for \(symbol)")
    }

    func stopAllAutoRefresh() {
        for (symbol, timer) in refreshTimers {
            timer.invalidate()
            print("[StockAPIService] ⏸️ Stopped auto-refresh for \(symbol)")
        }
        refreshTimers.removeAll()
    }

    // Force refresh (ignores cache)
    private func refreshStockData(symbol: String) async {
        guard !isLoading.contains(symbol) else {
            print("[StockAPIService] ⏸️ Already loading \(symbol), skipping refresh")
            return
        }

        print("[StockAPIService] 🔄 Auto-refreshing \(symbol)...")
        isLoading.insert(symbol)

        defer {
            isLoading.remove(symbol)
        }

        do {
            let stockData = try await performRequest(symbol: symbol)
            isLiveData[symbol] = true
            stockCache[symbol] = stockData
            print("[StockAPIService] ✅ Auto-refresh complete for \(symbol) - Price: $\(String(format: "%.2f", stockData.price))")
        } catch {
            print("[StockAPIService] ❌ Error refreshing \(symbol): \(error.localizedDescription)")
        }
    }

    func fetchStockData(symbol: String) async {
        guard !isLoading.contains(symbol) else {
            print("[StockAPIService] ⏸️ Already loading \(symbol), skipping duplicate request")
            return
        }

        // Check cache first (cache for 1 second to allow very frequent updates)
        if let cachedData = stockCache[symbol],
           Date().timeIntervalSince(cachedData.lastUpdated) < 1 {
            print("[StockAPIService] 💾 Using cached data for \(symbol) (age: \(Int(Date().timeIntervalSince(cachedData.lastUpdated)))s)")
            return
        }

        print("[StockAPIService] 🔄 Fetching fresh data for \(symbol)...")
        isLoading.insert(symbol)

        defer {
            isLoading.remove(symbol)
        }

        do {
            let stockData = try await performRequest(symbol: symbol)
            isLiveData[symbol] = true
            // Log successful live fetch
            logStockResult(symbol, quote: nil, candles: nil, usedMock: false)
            stockCache[symbol] = stockData
            NSLog("✅ [StockAPIService] Successfully cached LIVE data for \(symbol) - Price: $%.2f", stockData.price)
        } catch {
            NSLog("❌ [StockAPIService] Error fetching stock data for \(symbol): \(error.localizedDescription)")
            NSLog("📊 [StockAPIService] Falling back to MOCK data for \(symbol)")

            // Provide mock data for demo purposes
            stockCache[symbol] = createMockStockData(symbol: symbol)
            isLiveData[symbol] = false
            logStockResult(symbol, quote: nil, candles: nil, usedMock: true)
        }
    }
    
    private func performRequest(symbol: String) async throws -> StockData {
        if isCrypto(symbol) {
            // Use CoinGecko API for crypto - more reliable and free
            return try await fetchCryptoFromCoinGecko(symbol: symbol)
        } else {
            // Stock path (unchanged), narrow window to last 7 days but keep 60-min resolution
            let quoteURL = "\(baseURL)/quote?symbol=\(symbol)&token=\(apiKey)"
            guard let url = URL(string: quoteURL) else { throw URLError(.badURL) }

            let (quoteData, http1) = try await fetchData(from: url)
            print("[StockAPIService] Quote HTTP \(http1.statusCode) for \(symbol)")
            let quote = try JSONDecoder().decode(FinnhubQuote.self, from: quoteData)

            let toTimestamp = Int(Date().timeIntervalSince1970)
            let fromTimestamp = toTimestamp - (7 * 24 * 60 * 60)
            let candleURL = "\(baseURL)/stock/candle?symbol=\(symbol)&resolution=60&from=\(fromTimestamp)&to=\(toTimestamp)&token=\(apiKey)"
            guard let candleURLObj = URL(string: candleURL) else { throw URLError(.badURL) }

            let (candleData, http2) = try await fetchData(from: candleURLObj)
            print("[StockAPIService] Stock candles HTTP \(http2.statusCode) for \(symbol)")
            let candles = try JSONDecoder().decode(FinnhubCandle.self, from: candleData)

            let parsed = parseFinnhubData(symbol: symbol, quote: quote, candles: candles)
            logStockResult(symbol, quote: quote, candles: candles, usedMock: false)
            return parsed
        }
    }

    private func parseFinnhubData(symbol: String, quote: FinnhubQuote, candles: FinnhubCandle) -> StockData {
        guard candles.s == "ok", !candles.c.isEmpty else {
            print("[StockAPIService] Candle response not ok or empty for \(symbol). Falling back to mock.")
            isLiveData[symbol] = false
            return createMockStockData(symbol: symbol)
        }

        var chartPoints: [ChartPoint] = []

        for i in 0..<candles.c.count {
            let timestamp = Date(timeIntervalSince1970: TimeInterval(candles.t[i]))

            chartPoints.append(ChartPoint(
                timestamp: timestamp,
                price: candles.c[i],
                open: candles.o[i],
                high: candles.h[i],
                low: candles.l[i],
                close: candles.c[i],
                volume: candles.v[i]
            ))
        }

        chartPoints.sort { $0.timestamp < $1.timestamp }

        // Calculate change from previous close
        let currentPrice = quote.c
        let previousClose = quote.pc
        let change = currentPrice - previousClose
        let changePercent = (change / previousClose) * 100

        return StockData(
            symbol: symbol.uppercased(),
            price: currentPrice,
            change: change,
            changePercent: changePercent,
            chartData: chartPoints,
            lastUpdated: Date()
        )
    }
    
    // Mock data for demo/fallback
    private func createMockStockData(symbol: String) -> StockData {
        let basePrice: Double
        let mockChange: Double
        let mockChangePercent: Double
        
        switch symbol.uppercased() {
        case "NVDA":
            basePrice = 943.65
            mockChange = 174.32
            mockChangePercent = 22.7
        case "AAPL":
            basePrice = 185.45
            mockChange = 2.34
            mockChangePercent = 1.3
        case "TSLA":
            basePrice = 267.89
            mockChange = -5.67
            mockChangePercent = -2.1
        default:
            basePrice = Double.random(in: 50...500)
            mockChange = Double.random(in: -20...20)
            mockChangePercent = (mockChange / basePrice) * 100
        }
        
        // Generate mock chart data - enough points for all timeframes (60+ for 5Y)
        var chartPoints: [ChartPoint] = []
        let totalPoints = 100 // Generate 100 data points to cover all timeframes
        let startDate = Date().addingTimeInterval(-3600 * Double(totalPoints)) // Go back enough time

        for i in 0..<totalPoints {
            let timestamp = startDate.addingTimeInterval(Double(i) * 3600) // 1 hour intervals
            let variation = Double.random(in: -0.03...0.03)
            let close = basePrice * (1 + variation + (Double(i) / Double(totalPoints)) * (mockChangePercent / 100))
            let open = i > 0 ? chartPoints[i-1].close : close * 0.998
            let high = max(open, close) * Double.random(in: 1.002...1.01)
            let low = min(open, close) * Double.random(in: 0.99...0.998)
            let volume = Double.random(in: 1000000...10000000)

            chartPoints.append(ChartPoint(
                timestamp: timestamp,
                price: close,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume
            ))
        }
        
        return StockData(
            symbol: symbol.uppercased(),
            price: basePrice,
            change: mockChange,
            changePercent: mockChangePercent,
            chartData: chartPoints,
            lastUpdated: Date()
        )
    }

    // MARK: - News Fetching
    func fetchNews(symbol: String) async {
        // Check cache first (cache for 30 minutes)
        if let cachedNews = newsCache[symbol],
           !cachedNews.isEmpty {
            return
        }

        do {
            let newsArticles = try await performNewsRequest(symbol: symbol)
            newsCache[symbol] = newsArticles
        } catch {
            print("Error fetching news for \(symbol): \(error)")
            // Fallback to mock news if API fails
            newsCache[symbol] = createMockNews(symbol: symbol)
            print("[StockAPIService] Using MOCK news for \(symbol)")
        }
    }

    private func performNewsRequest(symbol: String) async throws -> [NewsArticle] {
        // Finnhub company news endpoint - last 7 days
        let toDate = ISO8601DateFormatter().string(from: Date()).prefix(10)
        let fromDate = ISO8601DateFormatter().string(from: Date().addingTimeInterval(-7 * 24 * 60 * 60)).prefix(10)

        let newsURL = "\(baseURL)/company-news?symbol=\(symbol)&from=\(fromDate)&to=\(toDate)&token=\(apiKey)"
        guard let url = URL(string: newsURL) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let finnhubNews = try JSONDecoder().decode([FinnhubNews].self, from: data)
        print("[StockAPIService] News items for \(symbol): \(finnhubNews.count)")

        // Convert to our NewsArticle model
        return finnhubNews.prefix(10).map { news in
            NewsArticle(
                id: String(news.id),
                headline: news.headline,
                source: news.source,
                url: news.url,
                summary: news.summary,
                imageURL: news.image.isEmpty ? nil : news.image,
                publishedAt: Date(timeIntervalSince1970: TimeInterval(news.datetime))
            )
        }
    }

    private func createMockNews(symbol: String) -> [NewsArticle] {
        let now = Date()
        let sym = symbol.uppercased()

        switch sym {
        case "NVDA":
            return [
                NewsArticle(id: UUID().uuidString, headline: "NVIDIA Announces New AI Chip Architecture", source: "TechCrunch", url: "https://techcrunch.com/tag/nvidia/", summary: "NVIDIA unveils groundbreaking AI chip design expected to revolutionize machine learning capabilities.", imageURL: nil, publishedAt: now.addingTimeInterval(-3600)),
                NewsArticle(id: UUID().uuidString, headline: "NVIDIA Stock Surges on Strong Q4 Earnings", source: "Bloomberg", url: "https://www.bloomberg.com/quote/NVDA:US", summary: "Company beats analyst expectations with record revenue from data center segment.", imageURL: nil, publishedAt: now.addingTimeInterval(-7200)),
                NewsArticle(id: UUID().uuidString, headline: "AI Demand Drives NVIDIA Growth", source: "Reuters", url: "https://www.reuters.com/technology/", summary: "Continued strong demand for AI infrastructure fuels NVIDIA's market dominance.", imageURL: nil, publishedAt: now.addingTimeInterval(-14400))
            ]
        case "AAPL":
            return [
                NewsArticle(id: UUID().uuidString, headline: "Apple Vision Pro Sees Strong Early Sales", source: "The Verge", url: "https://www.theverge.com/apple", summary: "Early adopters praise Apple's spatial computing device despite high price point.", imageURL: nil, publishedAt: now.addingTimeInterval(-3600)),
                NewsArticle(id: UUID().uuidString, headline: "Apple Expands Services Revenue", source: "WSJ", url: "https://www.wsj.com/market-data/quotes/AAPL", summary: "Services division continues to grow as hardware sales stabilize.", imageURL: nil, publishedAt: now.addingTimeInterval(-10800)),
                NewsArticle(id: UUID().uuidString, headline: "iPhone 16 Rumors Surface", source: "MacRumors", url: "https://www.macrumors.com", summary: "Leaks suggest major camera upgrades and new AI features coming this fall.", imageURL: nil, publishedAt: now.addingTimeInterval(-21600))
            ]
        case "TSLA":
            return [
                NewsArticle(id: UUID().uuidString, headline: "Tesla Cybertruck Production Ramps Up", source: "Electrek", url: "https://electrek.co/guides/tesla/", summary: "Tesla increases Cybertruck output as backlog of orders remains strong.", imageURL: nil, publishedAt: now.addingTimeInterval(-3600)),
                NewsArticle(id: UUID().uuidString, headline: "Musk Announces FSD Beta Update", source: "TechCrunch", url: "https://techcrunch.com/tag/tesla/", summary: "Latest Full Self-Driving update shows significant improvements in city driving.", imageURL: nil, publishedAt: now.addingTimeInterval(-7200)),
                NewsArticle(id: UUID().uuidString, headline: "Tesla Opens New Gigafactory in Mexico", source: "Reuters", url: "https://www.reuters.com/companies/TSLA.O", summary: "New production facility aims to meet growing demand in Latin America.", imageURL: nil, publishedAt: now.addingTimeInterval(-18000))
            ]
        case "BTC", "BITCOIN":
            return [
                NewsArticle(id: UUID().uuidString, headline: "Bitcoin ETFs See Record Inflows", source: "CoinDesk", url: "https://www.coindesk.com/business/", summary: "Institutional investors pour billions into spot Bitcoin ETFs.", imageURL: nil, publishedAt: now.addingTimeInterval(-3600)),
                NewsArticle(id: UUID().uuidString, headline: "Bitcoin Halving Approaches", source: "Decrypt", url: "https://decrypt.co/bitcoin", summary: "Next halving event expected to impact supply dynamics and price.", imageURL: nil, publishedAt: now.addingTimeInterval(-10800)),
                NewsArticle(id: UUID().uuidString, headline: "Major Bank Announces Bitcoin Custody Service", source: "Bloomberg", url: "https://www.bloomberg.com/crypto", summary: "Traditional finance continues to embrace cryptocurrency infrastructure.", imageURL: nil, publishedAt: now.addingTimeInterval(-25200))
            ]
        default:
            return [
                NewsArticle(id: UUID().uuidString, headline: "\(sym) Shows Strong Market Performance", source: "Financial Times", url: "https://www.ft.com/markets", summary: "Company continues to deliver solid results amid market volatility.", imageURL: nil, publishedAt: now.addingTimeInterval(-3600)),
                NewsArticle(id: UUID().uuidString, headline: "Analysts Upgrade \(sym) Rating", source: "MarketWatch", url: "https://www.marketwatch.com/investing", summary: "Multiple analysts raise price targets following recent earnings.", imageURL: nil, publishedAt: now.addingTimeInterval(-14400)),
                NewsArticle(id: UUID().uuidString, headline: "\(sym) Announces Strategic Partnership", source: "CNBC", url: "https://www.cnbc.com/business/", summary: "New collaboration expected to drive growth in key markets.", imageURL: nil, publishedAt: now.addingTimeInterval(-28800))
            ]
        }
    }
}
