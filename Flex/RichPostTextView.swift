import SwiftUI

struct RichPostTextView: View {
    var text: String
    var onTapTicker: (String) -> Void = { _ in }
    var onTapHashtag: (String) -> Void = { _ in }

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
        // Compose segments inline; tappable segments are rendered as buttons
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(segments) { seg in
                switch seg.kind {
                case .plain:
                    Text(seg.content)
                        .foregroundStyle(Theme.textPrimary)
                case .ticker(let sym):
                    Button(action: { onTapTicker(sym) }) {
                        Text("$" + sym)
                            .foregroundStyle(Theme.accentMuted)
                            .underline(false)
                    }
                    .buttonStyle(.plain)
                case .hashtag(let tag):
                    Button(action: { onTapHashtag(tag) }) {
                        Text("#" + tag)
                            .foregroundStyle(Theme.accentMuted)
                            .underline(false)
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Tokenization helpers
private func tokenize(_ input: String) -> [RichPostTextView.Segment] {
    // Find $TICKER (letters/numbers, typical) and #HASHTAG tokens, split the rest as plain
    // Regex: (\$[A-Za-z0-9]+)|(#\w+)
    let pattern = #"(\$[A-Za-z0-9]+)|(#[A-Za-z0-9_]+)"#
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return [RichPostTextView.Segment(content: input, kind: .plain)]
    }
    let ns = input as NSString
    let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: ns.length))

    var segments: [RichPostTextView.Segment] = []
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
