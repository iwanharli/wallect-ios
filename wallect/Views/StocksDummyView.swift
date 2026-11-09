import SwiftUI

struct StocksDummyView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddPortfolio = false
    @State private var showingAddWatchlist = false
    @State private var selectedHistoryStock: StockInfo? = nil
    
    struct StockInfo: Identifiable {
        let id = UUID()
        let symbol: String
        let name: String
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.DynamicBackground()
                
                // Animated glowing accent
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .blur(radius: 100)
                    .frame(width: 300, height: 300)
                    .offset(x: 100, y: -200)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Portfolio Summary Card (Modern Premium)
                        ZStack {
                            // Layered Glass & Glow Background
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white.opacity(0.03))
                                .background(
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 32)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.green.opacity(0.1), .clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                        
                                        // Dynamic Glow Pulse
                                        Circle()
                                            .fill(Color.green.opacity(0.12))
                                            .blur(radius: 40)
                                            .frame(width: 150)
                                            .offset(x: 100, y: -40)
                                    }
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 32)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            
                            VStack(spacing: 20) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("TOTAL NILAI PORTOFOLIO")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundColor(Theme.textSecondary)
                                            .tracking(1.8)
                                        
                                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                                            Text("Rp")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Theme.textSecondary)
                                            Text("25.450.000")
                                                .font(.system(size: 34, weight: .black, design: .rounded))
                                                .foregroundColor(.white)
                                                .monospacedDigit()
                                        }
                                        
                                        // Modern Growth Badge
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.up.right")
                                                .font(.system(size: 10, weight: .black))
                                            Text("+Rp 3.120.000 (14.2%)")
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                        }
                                        .foregroundColor(Color(hex: "2A9D8F"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(hex: "2A9D8F").opacity(0.12))
                                        .cornerRadius(12)
                                        .padding(.top, 4)
                                    }
                                    
                                    Spacer()
                                    
                                    // Animated Icon
                                    ZStack {
                                        Circle()
                                            .fill(Color.green.opacity(0.15))
                                            .frame(width: 54, height: 54)
                                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                                            .font(.system(size: 48))
                                            .foregroundColor(Color(hex: "2A9D8F"))
                                            .symbolEffect(.bounce, options: .repeating)
                                    }
                                }
                                
                                // Integrated Sparkline Visualization
                                HStack(spacing: 15) {
                                    Sparkline(data: [0.1, 0.4, 0.3, 0.7, 0.6, 0.9, 0.85, 1.0], color: Color(hex: "2A9D8F"))
                                        .frame(height: 35)
                                    
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("7D TREND")
                                            .font(.system(size: 8, weight: .black))
                                            .foregroundColor(Theme.textSecondary)
                                        Text("BULLISH")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Color(hex: "2A9D8F"))
                                    }
                                }
                                .padding(.top, 5)
                            }
                            .padding(24)
                        }
                        .padding(.horizontal, 20)
                        
                        // Portion: Portfolio List
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("PORTOFOLIO SAYA")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                                
                                Spacer()
                                Text("3 Emiten")
                                    .font(.caption2)
                                    .foregroundColor(Theme.textSecondary.opacity(0.6))
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                stockRow(symbol: "BBCA", name: "Bank Central Asia", price: "Rp 10.250", change: "+1.2%", isUp: true, detail: "10 Lot • Rp 10.25jt")
                                    .onTapGesture {
                                        HapticManager.shared.impact(.medium)
                                        selectedHistoryStock = StockInfo(symbol: "BBCA", name: "Bank Central Asia")
                                    }
                                
                                stockRow(symbol: "ASII", name: "Astra International", price: "Rp 5.125", change: "+3.5%", isUp: true, detail: "20 Lot • Rp 10.25jt")
                                    .onTapGesture {
                                        HapticManager.shared.impact(.medium)
                                        selectedHistoryStock = StockInfo(symbol: "ASII", name: "Astra International")
                                    }
                                
                                stockRow(symbol: "UNTR", name: "United Tractors", price: "Rp 24.750", change: "-0.8%", isUp: false, detail: "2 Lot • Rp 4.95jt")
                                    .onTapGesture {
                                        HapticManager.shared.impact(.medium)
                                        selectedHistoryStock = StockInfo(symbol: "UNTR", name: "United Tractors")
                                    }
                            }
                        }
                        
                        // Market Indices Snapshot
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INDEKS PASAR")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(Theme.textSecondary)
                                .tracking(1.5)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                marketStatusCard(title: "IHSG", value: "7.321,40", change: "+0,45%", isUp: true)
                                marketStatusCard(title: "LQ45", value: "982,12", change: "-0,12%", isUp: false)
                            }
                            .padding(.horizontal)
                        }

                        // Watchlist Dummy
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("PANTAUAN (WATCHLIST)")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Theme.textSecondary)
                                    .tracking(1.5)
                                
                                Button(action: { 
                                    HapticManager.shared.impact(.light)
                                    showingAddWatchlist = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(Theme.accent)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                stockRow(symbol: "TLKM", name: "Telkom Indonesia", price: "Rp 3.850", change: "-0.50%", isUp: false)
                                stockRow(symbol: "AMRT", name: "Sumber Alfaria Trijaya", price: "Rp 2.840", change: "+2,15%", isUp: true)
                                stockRow(symbol: "ICBP", name: "Indofood CBP", price: "Rp 11.200", change: "+0,45%", isUp: true)
                                stockRow(symbol: "GOTO", name: "GoTo Gojek Tokopedia", price: "Rp 64", change: "0,00%", isUp: true)
                            }
                        }
                        
                        Spacer(minLength: 120) // Extra space for FAB
                    }
                    .padding(.vertical)
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            showingAddPortfolio = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.accent, Theme.accent.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 64, height: 64)
                                    .shadow(color: Theme.accent.opacity(0.4), radius: 15, x: 0, y: 8)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.trailing, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Pasar Saham")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Theme.logoImage(size: 24)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingAddPortfolio) {
                AddPortfolioSheet()
                    .presentationDetents([.fraction(0.7)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAddWatchlist) {
                AddWatchlistSheet()
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedHistoryStock) { info in
                StockHistorySheet(symbol: info.symbol, name: info.name)
            }
        }
    }
    
    private func marketStatusCard(title: String, value: String, change: String, isUp: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundColor(Theme.textMain)
            Text(change)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isUp ? Color(hex: "2A9D8F") : Color(hex: "E63946"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.cardBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.glassBorder, lineWidth: 1)
                )
        )
    }
    
    private func stockRow(symbol: String, name: String, price: String, change: String, isUp: Bool, detail: String? = nil) -> some View {
        HStack(spacing: 16) {
            // Ticker Circle
            ZStack {
                Circle()
                    .fill(Color(hex: isUp ? "2A9D8F" : "E63946").opacity(0.1))
                    .frame(width: 44, height: 44)
                Text(symbol.prefix(1))
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(isUp ? Color(hex: "2A9D8F") : Color(hex: "E63946"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(symbol)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.textMain)
                Text(name)
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary)
                
                if let detail = detail {
                    Text(detail)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Theme.accent.opacity(0.8))
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(price)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textMain)
                
                HStack(spacing: 4) {
                    Image(systemName: isUp ? "arrow.up.right" : "arrow.down.left")
                        .font(.system(size: 8, weight: .bold))
                    Text(change)
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(isUp ? Color(hex: "2A9D8F") : Color(hex: "E63946"))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.glassBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

// MARK: - Sparkline Visualization
struct Sparkline: View {
    let data: [Double]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard data.count > 1 else { return }
                
                let step = geometry.size.width / CGFloat(data.count - 1)
                let height = geometry.size.height
                
                let points = data.enumerated().map { index, value in
                    CGPoint(x: CGFloat(index) * step, y: height * (1 - CGFloat(value)))
                }
                
                path.move(to: points[0])
                
                for i in 0..<points.count - 1 {
                    let p1 = points[i]
                    let p2 = points[i+1]
                    let midNode = CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
                    path.addQuadCurve(to: midNode, control: p1)
                    path.addQuadCurve(to: p2, control: midNode)
                }
            }
            .stroke(
                LinearGradient(
                    colors: [color, color.opacity(0.5)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}
