import SwiftUI

struct RichPostTextView: View {
    var text: String
    @State private var tickerToNavigate: String?
    @State private var hashtagToNavigate: String?

    private struct Segment: Identifiable {
        let id = UUID()
        let content: String
        let kind: Kind
        enum Kind { case plain, ticker(String), hashtag(String) }
    }

    private var segments: [Segment] {
        let normalized = TickerFormat.normalizePrefixes(in: text)
        return tokenize(normalized)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Build attributed text with tappable links
            Text(makeAttributedString())
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .environment(\.openURL, OpenURLAction { url in
                    handleURL(url)
                    return .handled
                })

            // Hidden NavigationLinks for programmatic navigation
            NavigationLink(
                destination: tickerToNavigate.map { TickerDetailView(symbol: $0) },
                tag: tickerToNavigate ?? "",
                selection: $tickerToNavigate
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: hashtagToNavigate.map { SearchView(initialSearchText: "#\($0)") },
                tag: hashtagToNavigate ?? "",
                selection: $hashtagToNavigate
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    private func makeAttributedString() -> AttributedString {
        var result = AttributedString()
        for seg in segments {
            switch seg.kind {
            case .plain:
                var plain = AttributedString(seg.content)
                plain.foregroundColor = Theme.textPrimary
                result.append(plain)
            case .ticker(let sym):
                var ticker = AttributedString("$" + sym)
                ticker.foregroundColor = Theme.accentMuted
                ticker.underlineStyle = .single
                ticker.link = URL(string: "ticker://\(sym)")
                result.append(ticker)
            case .hashtag(let tag):
                var hashtag = AttributedString("#" + tag)
                hashtag.foregroundColor = Theme.accentMuted
                hashtag.underlineStyle = .single
                hashtag.link = URL(string: "hashtag://\(tag)")
                result.append(hashtag)
            }
        }
        return result
    }

    private func handleURL(_ url: URL) {
        if url.scheme == "ticker", let sym = url.host {
            tickerToNavigate = sym
        } else if url.scheme == "hashtag", let tag = url.host {
            hashtagToNavigate = tag
        }
    }

    // MARK: - Tokenization helpers
    private func tokenize(_ input: String) -> [Segment] {
        // Find $TICKER (letters/numbers, typical) and #HASHTAG tokens, split the rest as plain
        // Regex: (\$[A-Za-z0-9]+)|(#\w+)
        let pattern = #"(\$[A-Za-z0-9]+)|(#[A-Za-z0-9_]+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [Segment(content: input, kind: .plain)]
        }
        let ns = input as NSString
        let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: ns.length))

        var segments: [Segment] = []
        var cursor = 0

        for m in matches {
            let range = m.range
            if range.location > cursor {
                let plain = ns.substring(with: NSRange(location: cursor, length: range.location - cursor))
                if !plain.isEmpty { segments.append(.init(content: plain, kind: .plain)) }
            }
            let token = ns.substring(with: range)
            if token.hasPrefix("$") {
                let sym = String(token.dropFirst())
                segments.append(.init(content: token, kind: .ticker(sym)))
            } else if token.hasPrefix("#") {
                let tag = String(token.dropFirst())
                segments.append(.init(content: token, kind: .hashtag(tag)))
            }
            cursor = range.location + range.length
        }

        if cursor < ns.length {
            let tail = ns.substring(from: cursor)
            if !tail.isEmpty { segments.append(.init(content: tail, kind: .plain)) }
        }
        return segments
    }
}

