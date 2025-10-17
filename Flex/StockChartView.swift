import SwiftUI
import Charts

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
            
            // Mini chart
            Chart {
                ForEach(stockData.chartData.suffix(30)) { point in
                    LineMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Time", point.timestamp),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green.opacity(0.3), .green.opacity(0.1), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .frame(height: 120)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: .automatic(includesZero: false))
            
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
                Chart {
                    ForEach(stockData.chartData) { point in
                        LineMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        
                        AreaMark(
                            x: .value("Time", point.timestamp),
                            y: .value("Price", point.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green.opacity(0.3), .green.opacity(0.1), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .frame(height: 300)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .omitted)).minute())
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
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