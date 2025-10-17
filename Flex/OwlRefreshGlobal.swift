import SwiftUI

// MARK: - Environment flag to enable owl refresh overlay globally
private struct OwlRefreshEnabledKey: EnvironmentKey { static let defaultValue: Bool = false }

extension EnvironmentValues {
    var owlRefreshEnabled: Bool {
        get { self[OwlRefreshEnabledKey.self] }
        set { self[OwlRefreshEnabledKey.self] = newValue }
    }
}

public extension View {
    /// Enable the owl pull-to-refresh overlay for scrollable content within this view hierarchy.
    func owlRefreshEnabled(_ enabled: Bool = true) -> some View {
        environment(\.owlRefreshEnabled, enabled)
    }
}

// Optional lightweight wrapper that conditionally embeds content in OwlRefreshContainer
// Note: OwlRefreshContainer is defined in OwlRefreshView.swift; we only reference it here.
@available(iOS 15.0, *)
struct OwlRefreshWrapper<Content: View>: View {
    @Environment(\.owlRefreshEnabled) private var enabled
    let onRefresh: () async -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        if enabled {
            OwlRefreshContainer(onRefresh: onRefresh) { content() }
        } else {
            content()
        }
    }
}

// Intentionally no #Preview here to avoid macro issues across deployment targets.

