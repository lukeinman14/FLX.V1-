import Foundation
import SwiftUI

// MARK: - Text Parser for Stock Tickers
struct PostTextParser {
    static func extractStockTickers(from text: String) -> Set<String> {
        let pattern = #"\$([A-Z]{1,5})\b"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var tickers = Set<String>()
        regex?.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            if let match = match,
               let tickerRange = Range(match.range(at: 1), in: text) {
                tickers.insert(String(text[tickerRange]))
            }
        }
        
        return tickers
    }
}

// MARK: - Rich Text View with Stock Ticker Highlighting
struct RichPostTextView: View {
    let text: String
    let stockTickers: Set<String>
    @StateObject private var stockAPI = StockAPIService.shared
    
    private let stockGreen = Color(red: 0.2, green: 0.8, blue: 0.4) // Bright green like in the concept
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Highlighted text
            highlightedText
                .font(.system(size: 16))
                .lineSpacing(2)
            
            // Stock charts for any mentioned tickers
            ForEach(Array(stockTickers), id: \.self) { ticker in
                if let stockData = stockAPI.stockCache[ticker] {
                    StockChartView(stockData: stockData)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else if stockAPI.isLoading.contains(ticker) {
                    stockLoadingView
                        .transition(.opacity)
                }
            }
        }
        .task {
            // Fetch stock data for mentioned tickers
            for ticker in stockTickers {
                await stockAPI.fetchStockData(symbol: ticker)
            }
        }
    }
    
    @ViewBuilder
    private var highlightedText: some View {
        let components = parseTextComponents(text)
        
        // Use Text concatenation for rich formatting
        components.reduce(Text("")) { result, component in
            switch component {
            case .regular(let text):
                return result + Text(text).foregroundColor(Theme.textPrimary)
            case .stockTicker(let ticker):
                return result + Text("$\(ticker)")
                    .foregroundColor(stockGreen)
                    .fontWeight(.semibold)
            }
        }
    }
    
    private var stockLoadingView: some View {
        HStack {
            ProgressView()
                .tint(stockGreen)
                .scaleEffect(0.8)
            Text("Loading chart...")
                .font(.system(size: 14))
                .foregroundStyle(Theme.textSecondary)
            Spacer()
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
    
    private func parseTextComponents(_ text: String) -> [TextComponent] {
        let pattern = #"\$([A-Z]{1,5})\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [.regular(text)]
        }
        
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let matches = regex.matches(in: text, options: [], range: range)
        
        var components: [TextComponent] = []
        var lastEndIndex = text.startIndex
        
        for match in matches {
            // Add regular text before the match
            if let matchRange = Range(match.range, in: text) {
                let beforeMatch = String(text[lastEndIndex..<matchRange.lowerBound])
                if !beforeMatch.isEmpty {
                    components.append(.regular(beforeMatch))
                }
                
                // Add the stock ticker
                if let tickerRange = Range(match.range(at: 1), in: text) {
                    let ticker = String(text[tickerRange])
                    components.append(.stockTicker(ticker))
                }
                
                lastEndIndex = matchRange.upperBound
            }
        }
        
        // Add remaining text after the last match
        if lastEndIndex < text.endIndex {
            let remainingText = String(text[lastEndIndex...])
            if !remainingText.isEmpty {
                components.append(.regular(remainingText))
            }
        }
        
        return components.isEmpty ? [.regular(text)] : components
    }
}

private enum TextComponent {
    case regular(String)
    case stockTicker(String)
}

// MARK: - Time formatting utilities
extension Date {
    func timeAgo() -> String {
        let now = Date()
        let interval = now.timeIntervalSince(self)
        
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: self)
        }
    }
}