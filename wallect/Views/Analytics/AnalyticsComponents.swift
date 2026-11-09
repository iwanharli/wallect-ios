import SwiftUI

struct SummaryCardPremium: View {
    let title: String
    let amount: Double
    let previousAmount: Double
    let color: Color
    let icon: String
    let isIncome: Bool
    let isSelected: Bool
    let action: () -> Void
    
    private var deltaPercentage: Double? {
        guard previousAmount > 0 else { return nil }
        return ((amount - previousAmount) / previousAmount) * 100
    }
    
    private var deltaColor: Color {
        guard let delta = deltaPercentage else { return .gray }
        if isIncome {
            return delta >= 0 ? Theme.income : Theme.expense
        } else {
            return delta <= 0 ? Theme.income : Theme.expense
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                }
                Spacer()
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(Theme.textSecondary)
                    .tracking(1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                NominalText(amount: amount, size: 17, color: .white)
                
                if let delta = deltaPercentage {
                    HStack(spacing: 4) {
                        Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 8, weight: .black))
                        Text("\(String(format: "%.0f%%", abs(delta))) vs bulan lalu")
                            .font(.system(size: 9, weight: .black))
                    }
                    .foregroundColor(deltaColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(deltaColor.opacity(0.15))
                    .cornerRadius(6)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            HapticManager.shared.impact(.medium)
            action()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(isSelected ? color.opacity(0.08) : Color.white.opacity(0.04))
                    .background(.ultraThinMaterial.opacity(isSelected ? 0.2 : 0.1))
                    .cornerRadius(24)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        isSelected ? color.opacity(0.8) : color.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1.5
                    )
                    .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 10)
            }
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct TopSpendingRow: View {
    let stat: CategoryStat
    let total: Double
    
    var body: some View {
        let progress = total > 0 ? CGFloat(stat.amount / total) : 0
        
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(stat.color.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: getIconForCategory(stat.name))
                    .font(.system(size: 12))
                    .foregroundColor(stat.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(stat.name)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    NominalText(amount: stat.amount, size: 14, color: .white)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                        Capsule()
                            .fill(stat.color)
                            .frame(width: geo.size.width * progress)
                            .shadow(color: stat.color.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
    
    private func getIconForCategory(_ name: String) -> String {
        switch name.lowercased() {
        case "food", "makan": return "fork.knife"
        case "shopping", "belanja": return "bag.fill"
        case "transport", "transportasi": return "car.fill"
        case "work", "kerja": return "briefcase.fill"
        case "gift", "hadiah": return "gift.fill"
        case "health", "kesehatan": return "heart.fill"
        case "other", "lainnya": return "tag.fill"
        default: return "creditcard.fill"
        }
    }
}

struct FinancialInsightsCard: View {
    let income: Double
    let expense: Double
    let savingsRate: Double
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.accent)
                    .symbolEffect(.bounce, options: .repeating)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("WAWASAN KAMU")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(Theme.accent)
                
                Text(insightText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(20)
        .background(Theme.accent.opacity(0.05))
        .background(.ultraThinMaterial.opacity(0.05))
        .cornerRadius(24)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.accent.opacity(0.1), lineWidth: 1))
    }
    
    private var insightText: String {
        if income > 0 && savingsRate > 0 {
            let percentage = String(format: "%.0f%%", savingsRate)
            if savingsRate >= 30 {
                return "Luar biasa! Kamu berhasil menabung \(percentage) dari pemasukkanmu bulan ini."
            } else if savingsRate >= 10 {
                return "Bagus! Kamu sudah menabung \(percentage), coba tingkatkan alokasimu sedikit lagi."
            } else {
                return "Kamu baru menabung \(percentage). Yuk, alokasikan lebih banyak ke Goal!"
            }
        }
        
        if expense > income && income > 0 {
            return "Pengeluaran Kamu melebihi pemasukan. Pertimbangkan untuk meninjau kategori belanja."
        } else if expense == 0 && income == 0 {
            return "Belum ada catatan transaksi. Kelola transaksi Kamu untuk melihat analisis."
        } else {
            return "Kesehatan keuangan Kamu terjaga! Simpan lebih banyak bulan ini."
        }
    }
}

struct CustomSegmentedPicker: View {
    @Binding var selection: String
    let options: [String]
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selection = option
                    }
                    HapticManager.shared.impact(.light)
                }) {
                    Text(option)
                        .font(.system(size: 13, weight: .black))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            ZStack {
                                if isSelected {
                                    Capsule()
                                        .fill(Theme.accent)
                                        .matchedGeometryEffect(id: "activeTab", in: namespace)
                                        .shadow(color: Theme.accent.opacity(0.3), radius: 5)
                                }
                            }
                        )
                        .foregroundColor(isSelected ? .black : Theme.textSecondary)
                }
            }
        }
        .padding(4)
        .background(Color.white.opacity(0.05))
        .background(.ultraThinMaterial.opacity(0.1))
        .clipShape(Capsule())
    }
}
