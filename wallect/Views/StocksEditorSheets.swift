import SwiftUI

struct AddPortfolioSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var symbol: String = ""
    @State private var lots: String = ""
    @State private var avgPrice: String = ""
    @State private var isSaving = false
    
    // Animation states
    @State private var isSymbolFocused = false
    @State private var isLotsFocused = false
    @State private var isPriceFocused = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            // Dynamic Background Glow
            Circle()
                .fill(tickerColor.opacity(0.15))
                .blur(radius: 80)
                .frame(width: 400)
                .offset(y: -250)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // Header & Indicator
                    VStack(spacing: 12) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 40, height: 4)
                        
                        Text("Asset Baru")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 12)
                    
                    // Live Card Preview
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [tickerColor.opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(Color.white.opacity(0.03))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(tickerColor.opacity(0.3), lineWidth: 1)
                                )
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Circle()
                                        .fill(tickerColor.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Text(symbol.isEmpty ? "?" : String(symbol.prefix(1)))
                                                .font(.system(size: 20, weight: .black))
                                                .foregroundColor(tickerColor)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(symbol.isEmpty ? "EMITEN" : symbol.uppercased())
                                            .font(.system(size: 22, weight: .black, design: .rounded))
                                            .foregroundColor(.white)
                                        Text("Market Order • New Acquisition")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    Spacer()
                                }
                                
                                Divider().background(Color.white.opacity(0.1))
                                
                                HStack {
                                    previewDetail(label: "LOTS", value: lots.isEmpty ? "0" : lots, color: .purple)
                                    Spacer()
                                    previewDetail(label: "AVG PRICE", value: avgPrice.isEmpty ? "0" : "Rp \(avgPrice)", color: Color(hex: "FFB800"))
                                }
                            }
                            .padding(24)
                        }
                        .frame(height: 180)
                        .padding(.horizontal, 24)
                    }
                    
                    // Input Form
                    VStack(spacing: 24) {
                        // Symbol Input (Cyan)
                        vibrantInput(
                            title: "KODE EMITEN",
                            icon: "tag.fill",
                            placeholder: "MISAL: BBCA",
                            text: $symbol,
                            color: Color(hex: "00F0FF"),
                            isFocused: isSymbolFocused,
                            onFocusChange: { isSymbolFocused = $0 }
                        )
                        .onChange(of: symbol) {
                            HapticManager.shared.impact(.light)
                        }
                        
                        HStack(spacing: 20) {
                            // Lots Input (Purple)
                            vibrantInput(
                                title: "LOT",
                                icon: "chart.pie.fill",
                                placeholder: "0",
                                text: $lots,
                                color: .purple,
                                isFocused: isLotsFocused,
                                onFocusChange: { isLotsFocused = $0 },
                                keyboardType: .numberPad
                            )
                            
                            // Price Input (Gold)
                            vibrantInput(
                                title: "HARGA",
                                icon: "banknote.fill",
                                placeholder: "0",
                                text: $avgPrice,
                                color: Color(hex: "FFB800"),
                                isFocused: isPriceFocused,
                                onFocusChange: { isPriceFocused = $0 },
                                keyboardType: .numberPad
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                    
                    // Hero Save Button
                    Button(action: save) {
                        ZStack {
                            if isSaving {
                                ProgressView().tint(.black)
                            } else {
                                HStack(spacing: 12) {
                                    Text("Tambah Portofolio")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                }
                                .foregroundColor(.black)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(
                            Capsule()
                                .fill(tickerColor)
                                .shadow(color: tickerColor.opacity(0.4), radius: 20, x: 0, y: 10)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    .disabled(symbol.isEmpty || lots.isEmpty || avgPrice.isEmpty)
                    .opacity((symbol.isEmpty || lots.isEmpty || avgPrice.isEmpty) ? 0.4 : 1.0)
                }
            }
        }
    }
    
    private var tickerColor: Color {
        if symbol.isEmpty { return Theme.accent }
        let colors: [Color] = [Color(hex: "00F0FF"), Color(hex: "AD00FF"), Color(hex: "FFB800"), Color(hex: "2A9D8F")]
        let index = abs(symbol.hashValue) % colors.count
        return colors[index]
    }
    
    private func previewDetail(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }
    
    private func vibrantInput(
        title: String,
        icon: String,
        placeholder: String,
        text: Binding<String>,
        color: Color,
        isFocused: Bool,
        onFocusChange: @escaping (Bool) -> Void,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
            }
            .foregroundColor(text.wrappedValue.isEmpty ? Theme.textSecondary : color)
            
            TextField(placeholder, text: text)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .keyboardType(keyboardType)
                .autocapitalization(.allCharacters)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isFocused ? color : Theme.glassBorder, lineWidth: 1.5)
                        )
                        .shadow(color: isFocused ? color.opacity(0.2) : .clear, radius: 10)
                )
        }
    }
    
    private func save() {
        HapticManager.shared.impact(.medium)
        withAnimation { isSaving = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            HapticManager.shared.notification(.success)
            dismiss()
        }
    }
}

struct AddWatchlistSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchQuery: String = ""
    @State private var isSearching = false
    
    let suggestions = [
        ("BBCA", "Bank Central Asia"),
        ("TLKM", "Telkom Indonesia"),
        ("ASII", "Astra International"),
        ("UNTR", "United Tractors"),
        ("ICBP", "Indofood CBP"),
        ("GOTO", "GoTo Gojek Tokopedia")
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 20) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                    
                    Text("Tambah Pantauan")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Theme.textSecondary)
                        
                        TextField("Cari kode atau nama emiten", text: $searchQuery)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Theme.cardBackground.opacity(0.6))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.glassBorder, lineWidth: 1))
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 25)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("SARAN UNTUK KAMU")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.textSecondary)
                            .tracking(1.5)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(suggestions, id: \.0) { symbol, name in
                                suggestionRow(symbol: symbol, name: name)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
    
    private func suggestionRow(symbol: String, name: String) -> some View {
        Button(action: {
            HapticManager.shared.impact(.medium)
            dismiss()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 44, height: 44)
                Text(symbol.prefix(1))
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(Theme.accent)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text(name)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.accent)
            }
            .padding(14)
            .background(Theme.cardBackground.opacity(0.3))
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.glassBorder, lineWidth: 1))
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stock History Sheet
struct StockHistorySheet: View {
    @Environment(\.dismiss) var dismiss
    let symbol: String
    let name: String
    
    struct Transaction: Identifiable {
        let id = UUID()
        let type: String // "BELI" or "JUAL"
        let date: String
        let price: String
        let lots: String
        let total: String
        let isBuy: Bool
    }
    
    let dummyHistory: [Transaction] = [
        Transaction(type: "BELI", date: "12 Mar 2026", price: "Rp 9.850", lots: "5 Lot", total: "Rp 4.925.000", isBuy: true),
        Transaction(type: "BELI", date: "28 Feb 2026", price: "Rp 10.125", lots: "5 Lot", total: "Rp 5.062.500", isBuy: true),
        Transaction(type: "JUAL", date: "15 Jan 2026", price: "Rp 10.450", lots: "2 Lot", total: "Rp 2.090.000", isBuy: false)
    ]
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                    
                    Text("Riwayat Transaksi")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.top, 4)
                    
                    Text(symbol)
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.bottom, 25)
                
                // Summary Card
                HStack(spacing: 20) {
                    summaryItem(title: "TOTAL LOT", value: "8 Lot")
                    Divider().background(Color.white.opacity(0.1)).frame(height: 30)
                    summaryItem(title: "AVG PRICE", value: "Rp 9.987")
                    Divider().background(Color.white.opacity(0.1)).frame(height: 30)
                    summaryItem(title: "EST. PROFIT", value: "+12.4%", color: .green)
                }
                .padding()
                .background(Theme.cardBackground.opacity(0.4))
                .cornerRadius(24)
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.glassBorder, lineWidth: 1))
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                
                // History List
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("AKTIVITAS TRANSAKSI")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(Theme.textSecondary)
                            .tracking(1.5)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(dummyHistory) { tx in
                                transactionRow(tx: tx)
                            }
                        }
                    }
                    Spacer(minLength: 120) // Give space for bottom buttons
                }
            }
            
            // Sticky Bottom Actions
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    // JUAL Button
                    Button(action: {
                        HapticManager.shared.notification(.warning)
                    }) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("JUAL")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "E63946"))
                                .shadow(color: Color(hex: "E63946").opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                    
                    // BELI Button
                    Button(action: {
                        HapticManager.shared.notification(.success)
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("BELI")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "2A9D8F"))
                                .shadow(color: Color(hex: "2A9D8F").opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                    }
                }
                .padding(20)
                .background(
                    Theme.cardBackground.opacity(0.8)
                        .background(.ultraThinMaterial)
                        .overlay(
                            Rectangle().stroke(Theme.glassBorder, lineWidth: 0.5)
                        , alignment: .top)
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private func summaryItem(title: String, value: String, color: Color = .white) -> some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Theme.textSecondary)
            Text(value)
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func transactionRow(tx: Transaction) -> some View {
        HStack(spacing: 16) {
            // Type Indicator
            ZStack {
                Circle()
                    .fill((tx.isBuy ? Color.green : Color.red).opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: tx.isBuy ? "arrow.down.left" : "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(tx.isBuy ? .green : .red)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.type)
                    .font(.system(size: 13, weight: .black))
                    .foregroundColor(tx.isBuy ? .green : .red)
                Text(tx.date)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(tx.total)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("\(tx.lots) @ \(tx.price)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(14)
        .background(Theme.cardBackground.opacity(0.3))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.glassBorder, lineWidth: 1))
        .padding(.horizontal, 24)
    }
}
