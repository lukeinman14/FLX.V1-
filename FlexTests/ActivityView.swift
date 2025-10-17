import SwiftUI

struct ActivityView: View {
    // Sample random data for the line graph
    private let data: [CGFloat] = (0..<20).map { _ in CGFloat.random(in: 10...100) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Portfolio Growth & Activity")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("FlexPrimary"))
                .padding(.horizontal)
            
            LineChart(data: data)
                .frame(height: 150)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                ActivityCard(title: "Weekly Change", value: "+4.2%", color: Color("FlexGreen"))
                ActivityCard(title: "Weekly Change", value: "-1.3%", color: Color("FlexRed"))
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .background(Color("FlexBackground").ignoresSafeArea())
    }
}

private struct LineChart: View {
    let data: [CGFloat]
    
    private var maxData: CGFloat {
        data.max() ?? 1
    }
    
    private var minData: CGFloat {
        data.min() ?? 0
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let step = width / CGFloat(data.count - 1)
            
            // Path for line graph
            Path { path in
                for index in data.indices {
                    let x = step * CGFloat(index)
                    let y = height - ( (data[index] - minData) / (maxData - minData) * height )
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color("FlexPrimary"), lineWidth: 2)
            .shadow(color: Color("FlexPrimary").opacity(0.3), radius: 4, x: 0, y: 2)
            
            // Circles on data points
            ForEach(data.indices, id: \.self) { index in
                let x = step * CGFloat(index)
                let y = height - ( (data[index] - minData) / (maxData - minData) * height )
                Circle()
                    .fill(Color("FlexPrimary"))
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
                    .shadow(color: Color("FlexPrimary").opacity(0.6), radius: 3, x: 0, y: 1)
            }
        }
    }
}

private struct ActivityCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color.opacity(0.8))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color("FlexCardBackground"))
        .cornerRadius(12)
        .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ActivityView()
                .preferredColorScheme(.light)
            ActivityView()
                .preferredColorScheme(.dark)
        }
        // Define FlexTheme sample colors to preview
        .environment(\.colorScheme, .light)
        .environment(\.colorScheme, .dark)
    }
}
