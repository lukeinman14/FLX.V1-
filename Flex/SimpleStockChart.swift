import SwiftUI

struct StockChartView: View {
    let stockData: StockData
    @State private var showFullChart = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Stock price and change info
            HStack {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(stockData.price, specifier: "%.2f")")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.green)
                        )
                    
                    Text("\(stockData.change >= 0 ? "+" : "")\(stockData.changePercent, specifier: "%.1f")%")
                        .font(.system(size: 14))
                        .foregroundStyle(stockData.change >= 0 ? .green : .red)
                }
            }
            
            // Simple line chart using Path
            GeometryReader { geometry in
                if !stockData.chartData.isEmpty {
                    let chartData = stockData.chartData.suffix(30)
                    let minPrice = chartData.map(\.price).min() ?? 0
                    let maxPrice = chartData.map(\.price).max() ?? 1
                    let priceRange = maxPrice - minPrice
                    
                    ZStack {
                        // Background gradient
                        Path { path in
                            let points = chartData.enumerated().map { index, point in
                                let x = CGFloat(index) / CGFloat(chartData.count - 1) * geometry.size.width
                                let y = geometry.size.height - ((point.price - minPrice) / priceRange * geometry.size.height)
                                return CGPoint(x: x, y: y)
                            }
                            
                            if let first = points.first {
                                path.move(to: CGPoint(x: first.x, y: geometry.size.height))
                                path.addLine(to: first)
                                
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                                
                                path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: geometry.size.height))
                                path.closeSubpath()
                            }
                        }
                        .fill(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.1), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line chart
                        Path { path in
                            let points = chartData.enumerated().map { index, point in
                                let x = CGFloat(index) / CGFloat(chartData.count - 1) * geometry.size.width
                                let y = geometry.size.height - ((point.price - minPrice) / priceRange * geometry.size.height)
                                return CGPoint(x: x, y: y)
                            }
                            
                            if let first = points.first {
                                path.move(to: first)
                                
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                        }
                        .stroke(.green, lineWidth: 2)
                    }
                }
            }
            .frame(height: 120)
            
            // Time labels
            HStack {
                ForEach(timeLabels, id: \.self) { label in
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                    if label != timeLabels.last {
                        Spacer()
                    }
                }
            }
            
            // View Full Chart button
            Button(action: { showFullChart = true }) {
                HStack(spacing: 4) {
                    Text("View Full Chart")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textPrimary)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textPrimary)
                }
            }
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
        .sheet(isPresented: $showFullChart) {
            FullStockChartView(stockData: stockData)
        }
    }
    
    private var timeLabels: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let chartData = stockData.chartData.suffix(30)
        guard let first = chartData.first?.timestamp,
              let last = chartData.last?.timestamp else {
            return ["14:00", "10:30", "12:30", "10:30"]
        }
        
        let interval = last.timeIntervalSince(first) / 3
        
        return [
            formatter.string(from: first),
            formatter.string(from: first.addingTimeInterval(interval)),
            formatter.string(from: first.addingTimeInterval(interval * 2)),
            formatter.string(from: last)
        ]
    }
}

struct FullStockChartView: View {
    let stockData: StockData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header with stock info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stockData.symbol)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Theme.textPrimary)
                        
                        Text("$\(stockData.price, specifier: "%.2f")")
                            .font(.system(size: 24))
                            .foregroundStyle(Theme.textPrimary)
                        
                        HStack(spacing: 4) {
                            Text("\(stockData.change >= 0 ? "+" : "")\(stockData.change, specifier: "%.2f")")
                            Text("(\(stockData.change >= 0 ? "+" : "")\(stockData.changePercent, specifier: "%.2f")%)")
                        }
                        .font(.system(size: 16))
                        .foregroundStyle(stockData.change >= 0 ? .green : .red)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                // Full chart
                GeometryReader { geometry in
                    if !stockData.chartData.isEmpty {
                        let minPrice = stockData.chartData.map(\.price).min() ?? 0
                        let maxPrice = stockData.chartData.map(\.price).max() ?? 1
                        let priceRange = maxPrice - minPrice
                        
                        ZStack {
                            // Background gradient
                            Path { path in
                                let points = stockData.chartData.enumerated().map { index, point in
                                    let x = CGFloat(index) / CGFloat(stockData.chartData.count - 1) * geometry.size.width
                                    let y = geometry.size.height - ((point.price - minPrice) / priceRange * geometry.size.height)
                                    return CGPoint(x: x, y: y)
                                }
                                
                                if let first = points.first {
                                    path.move(to: CGPoint(x: first.x, y: geometry.size.height))
                                    path.addLine(to: first)
                                    
                                    for point in points.dropFirst() {
                                        path.addLine(to: point)
                                    }
                                    
                                    path.addLine(to: CGPoint(x: points.last?.x ?? 0, y: geometry.size.height))
                                    path.closeSubpath()
                                }
                            }
                            .fill(
                                LinearGradient(
                                    colors: [.green.opacity(0.3), .green.opacity(0.1), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Line chart
                            Path { path in
                                let points = stockData.chartData.enumerated().map { index, point in
                                    let x = CGFloat(index) / CGFloat(stockData.chartData.count - 1) * geometry.size.width
                                    let y = geometry.size.height - ((point.price - minPrice) / priceRange * geometry.size.height)
                                    return CGPoint(x: x, y: y)
                                }
                                
                                if let first = points.first {
                                    path.move(to: first)
                                    
                                    for point in points.dropFirst() {
                                        path.addLine(to: point)
                                    }
                                }
                            }
                            .stroke(.green, lineWidth: 3)
                        }
                    }
                }
                .frame(height: 300)
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Theme.bg)
            .navigationTitle("Stock Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let mockData = StockData(
        symbol: "NVDA",
        price: 943.65,
        change: 174.32,
        changePercent: 22.7,
        chartData: [],
        lastUpdated: Date()
    )
    
    return StockChartView(stockData: mockData)
        .padding()
        .background(Theme.bg)
        .preferredColorScheme(.dark)
}