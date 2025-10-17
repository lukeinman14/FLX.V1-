import SwiftUI

@available(iOS 15, *)
private struct OwlRefreshEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

@available(iOS 15, *)
extension EnvironmentValues {
    var owlRefreshEnabled: Bool {
        get { self[OwlRefreshEnabledKey.self] }
        set { self[OwlRefreshEnabledKey.self] = newValue }
    }
}

@available(iOS 15, *)
extension View {
    func owlRefreshEnabled(_ enabled: Bool = true) -> some View {
        environment(\.owlRefreshEnabled, enabled)
    }
    
    func owlRefreshContainer(onRefresh: @escaping () async -> Void = {}) -> some View {
        OwlRefreshWrapper(content: { self }, onRefresh: onRefresh)
    }
}

@available(iOS 15, *)
private struct OwlRefreshWrapper<Content: View>: View {
    @Environment(\.owlRefreshEnabled) private var enabled
    let content: () -> Content
    let onRefresh: () async -> Void
    
    var body: some View {
        if enabled {
            OwlRefreshContainer(onRefresh: onRefresh) {
                content()
            }
        } else {
            content()
        }
    }
}

@available(iOS 15, *)
struct OwlRefreshContainer<Content: View>: View {
    let onRefresh: () async -> Void
    let content: () -> Content
    
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear.preference(key: RefreshKey.self, value: geo.frame(in: .global).minY)
            }
            .frame(height: 0)
            
            content()
        }
        .overlay {
            if isRefreshing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 10)
            }
        }
        .onPreferenceChange(RefreshKey.self) { minY in
            if !isRefreshing && minY > 50 {
                Task {
                    isRefreshing = true
                    await onRefresh()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRefreshing = false
                    }
                }
            }
        }
    }
    
    private struct RefreshKey: PreferenceKey {
        static var defaultValue: CGFloat = 0
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }
}

#Preview {
    struct ContentView: View {
        @State private var items = Array(0..<20)
        
        var body: some View {
            List(items, id: \.self) { item in
                Text("Item \(item)")
            }
            .owlRefreshEnabled(true)
            .owlRefreshContainer {
                await refresh()
            }
        }
        
        func refresh() async {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            items.append(items.count)
        }
    }
    
    ContentView()
}
