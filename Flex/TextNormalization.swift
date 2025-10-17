import Foundation

enum TickerFormat {
    /// Normalize duplicate ticker prefixes so text like "$$NVDA" -> "$NVDA" and "###AI" -> "#AI".
    /// Also prefers $ for tickers if both # and $ are adjacent (e.g., "#$AAPL" -> "$AAPL").
    static func normalizePrefixes(in text: String) -> String {
        var normalized = text
        // Collapse multiple $ into one
        normalized = normalized.replacingOccurrences(of: #"\${2,}"#, with: "$", options: .regularExpression)
        // Collapse multiple # into one
        normalized = normalized.replacingOccurrences(of: #"#{2,}"#, with: "#", options: .regularExpression)
        // Fix cases like "#$AAPL" -> "$AAPL" and "$#AAPL" -> "$AAPL"
        normalized = normalized.replacingOccurrences(of: #"#\$(\w+)"#, with: #"$$1"#, options: .regularExpression)
        normalized = normalized.replacingOccurrences(of: #"\$#(\w+)"#, with: #"$$1"#, options: .regularExpression)
        return normalized
    }
}
