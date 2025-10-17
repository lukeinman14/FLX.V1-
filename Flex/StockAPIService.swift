import Foundation
import SwiftUI

// MARK: - Alpha Vantage API Models
struct AlphaVantageResponse: Codable {
    let metaData: MetaData
    let timeSeries: [String: TimeSeriesData]
    
    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeries = "Time Series (5min)"
    }
}

struct MetaData: Codable {
    let information: String
    let symbol: String
    let lastRefreshed: String
    let interval: String
    let outputSize: String
    let timeZone: String
    
    enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case interval = "4. Interval"
        case outputSize = "5. Output Size"
        case timeZone = "6. Time Zone"
    }
}

struct TimeSeriesData: Codable {
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    
    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}

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
    let high: Double
    let low: Double
}

// MARK: - Stock API Service
@MainActor
class StockAPIService: ObservableObject {
    static let shared = StockAPIService()
    
    // Get your free API key from: https://www.alphavantage.co/support/#api-key
    private let apiKey = "demo" // Replace with your actual API key
    private let baseURL = "https://www.alphavantage.co/query"
    
    @Published var stockCache: [String: StockData] = [:]
    @Published var isLoading: Set<String> = []
    
    private init() {}
    
    func fetchStockData(symbol: String) async {
        guard !isLoading.contains(symbol) else { return }
        
        // Check cache first (cache for 5 minutes)
        if let cachedData = stockCache[symbol],
           Date().timeIntervalSince(cachedData.lastUpdated) < 300 {
            return
        }
        
        isLoading.insert(symbol)
        
        defer {
            isLoading.remove(symbol)
        }
        
        do {
            let stockData = try await performRequest(symbol: symbol)
            stockCache[symbol] = stockData
        } catch {
            print("Error fetching stock data for \(symbol): \(error)")
            
            // Provide mock data for demo purposes
            stockCache[symbol] = createMockStockData(symbol: symbol)
        }
    }
    
    private func performRequest(symbol: String) async throws -> StockData {
        let urlString = "\(baseURL)?function=TIME_SERIES_INTRADAY&symbol=\(symbol)&interval=5min&apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AlphaVantageResponse.self, from: data)
        
        return parseStockData(response: response)
    }
    
    private func parseStockData(response: AlphaVantageResponse) -> StockData {
        let sortedTimes = response.timeSeries.keys.sorted(by: >)
        
        guard let latestTime = sortedTimes.first,
              let latestData = response.timeSeries[latestTime],
              let currentPrice = Double(latestData.close) else {
            return createMockStockData(symbol: response.metaData.symbol)
        }
        
        var chartPoints: [ChartPoint] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for timeKey in sortedTimes.prefix(50) { // Last 50 data points
            if let data = response.timeSeries[timeKey],
               let price = Double(data.close),
               let high = Double(data.high),
               let low = Double(data.low),
               let date = dateFormatter.date(from: timeKey) {
                
                chartPoints.append(ChartPoint(
                    timestamp: date,
                    price: price,
                    high: high,
                    low: low
                ))
            }
        }
        
        chartPoints.sort { $0.timestamp < $1.timestamp }
        
        // Calculate change from previous day
        let change = chartPoints.count > 1 ? currentPrice - chartPoints.first!.price : 0
        let changePercent = chartPoints.count > 1 ? (change / chartPoints.first!.price) * 100 : 0
        
        return StockData(
            symbol: response.metaData.symbol,
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
        
        // Generate mock chart data
        var chartPoints: [ChartPoint] = []
        let startDate = Date().addingTimeInterval(-3600 * 6) // 6 hours ago
        
        for i in 0..<72 { // 72 data points (5-minute intervals over 6 hours)
            let timestamp = startDate.addingTimeInterval(Double(i) * 300) // 300 seconds = 5 minutes
            let variation = Double.random(in: -0.02...0.02)
            let price = basePrice * (1 + variation + (Double(i) / 72) * (mockChangePercent / 100))
            
            chartPoints.append(ChartPoint(
                timestamp: timestamp,
                price: price,
                high: price * 1.005,
                low: price * 0.995
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
}