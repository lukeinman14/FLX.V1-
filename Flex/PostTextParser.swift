import Foundation
import Foundation
import SwiftUI
import Combine

// MARK: - Text Parser for Stock Tickers and Hashtags
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
    
    static func extractHashtags(from text: String) -> Set<String> {
        let pattern = #"#([A-Za-z0-9_]+)\b"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        
        var hashtags = Set<String>()
        regex?.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
            if let match = match,
               let hashtagRange = Range(match.range(at: 1), in: text) {
                hashtags.insert(String(text[hashtagRange]))
            }
        }
        
        return hashtags
    }
}

// MARK: - Text Component Helpers (Removed duplicate RichPostTextView - see RichPostTextView.swift)

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