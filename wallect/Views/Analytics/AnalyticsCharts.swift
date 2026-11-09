import SwiftUI

struct DonutChartPremium: View {
    let segments: [CategoryStat]
    @State private var innerAnimation: CGFloat = 0
    
    var body: some View {
        let totalAmount = segments.reduce(0) { $0 + $1.amount }
        
        ZStack {
            // Ambient Halo Glow
            Circle()
                .stroke((segments.first?.color ?? Theme.accent).opacity(Double(0.05 * innerAnimation)), lineWidth: 40)
                .blur(radius: 10)
            
            // Background Track
            Circle()
                .stroke(Color.white.opacity(0.03), lineWidth: 24)
            
            ForEach(0..<segments.count, id: \.self) { index in
                Circle()
                    .trim(from: startProgress(for: index, total: totalAmount), to: endProgress(for: index, total: totalAmount) * innerAnimation)
                    .stroke(
                        segments[index].color,
                        style: StrokeStyle(lineWidth: 24, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: segments[index].color.opacity(0.3), radius: 8)
            }
            
            VStack(spacing: 2) {
                Text("TOTAL")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(1)
                NominalText(
                    amount: totalAmount,
                    size: 14,
                    color: .white
                )
                .scaleEffect(1.0 + Double(innerAnimation * 0.05))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7)) {
                innerAnimation = 1.0
            }
        }
    }
    
    private func startProgress(for index: Int, total: Double) -> CGFloat {
        guard total > 0 else { return 0 }
        let sum = segments.prefix(index).reduce(0) { $0 + $1.amount }
        return CGFloat(sum / total)
    }
    
    private func endProgress(for index: Int, total: Double) -> CGFloat {
        guard total > 0 else { return 0 }
        let sum = segments.prefix(index + 1).reduce(0) { $0 + $1.amount }
        return CGFloat(sum / total)
    }
}

struct BarChartPremium: View {
    let data: [Double]
    var color: Color = Theme.accent
    @State private var animate = false
    
    var body: some View {
        let maxVal = (data.max() ?? 1) == 0 ? 1 : (data.max() ?? 1)
        
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack(spacing: 12) {
                    ZStack(alignment: .bottom) {
                        Capsule()
                            .fill(Color.white.opacity(0.03))
                            .frame(width: 14, height: 120)
                        
                        if data[index] > 0 {
                            let barHeight = CGFloat(data[index] / maxVal) * 120
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [color, color.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 14, height: animate ? barHeight : 0)
                                .shadow(color: color.opacity(0.3), radius: 6)
                        }
                    }
                    
                    Text(getDayName(index))
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animate = true
            }
        }
    }
    
    private func getDayName(_ index: Int) -> String {
        let days = ["S", "S", "R", "K", "J", "S", "M"]
        return days[index]
    }
}

struct MonthlyBarChartPremium: View {
    let stats: [MonthlyStat]
    var color: Color = Theme.expense
    @State private var animate = false
    
    var body: some View {
        let maxAmt = stats.map { $0.amount }.max() ?? 1
        let safeMax = maxAmt == 0 ? 1 : maxAmt
        
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(stats) { stat in
                VStack(spacing: 12) {
                    ZStack(alignment: .bottom) {
                        Capsule()
                            .fill(Color.white.opacity(0.03))
                            .frame(width: 18, height: 120)
                        
                        if stat.amount > 0 {
                            let barHeight = CGFloat(stat.amount / safeMax) * 120
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [color.opacity(0.8), color.opacity(0.4)], startPoint: .top, endPoint: .bottom)
                                )
                                .frame(width: 18, height: animate ? barHeight : 0)
                                .shadow(color: color.opacity(0.2), radius: 6)
                        }
                    }
                    
                    Text(stat.name)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animate = true
            }
        }
    }
}
