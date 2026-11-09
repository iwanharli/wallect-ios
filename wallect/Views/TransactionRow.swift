import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    @Query var categories: [Category]
    
    
    private var categoryData: Category? {
        categories.first(where: { $0.name == transaction.category })
    }
    
    private var accentColor: Color {
        if transaction.isSystem { return Color.indigo }
        if let hex = categoryData?.hexColor {
            return Color(hex: hex)
        }
        return transaction.isExpense ? Theme.expense : Theme.income
    }
    
    private var iconName: String {
        if transaction.isSystem { return "square.stack.3d.up.fill" }
        return categoryData?.icon ?? "dollarsign.circle"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with Ambient Glow
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(accentColor)
                    .shadow(color: transaction.isSystem ? Color.indigo.opacity(0.3) : .clear, radius: 5)
            }
            .overlay(
                Circle()
                    .stroke(accentColor.opacity(0.1), lineWidth: 1)
            )
            
            // Details
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(transaction.isSystem ? "OTOMATIS" : transaction.category)
                    .font(.system(size: 9, weight: .black))
                    .foregroundColor(transaction.isSystem ? Color.indigo.opacity(0.8) : Theme.textSecondary.opacity(0.7))
                    .tracking(1.5)
                    .textCase(.uppercase)
            }
            
            Spacer()
            
            // Amount & Badge
            VStack(alignment: .trailing, spacing: 4) {
                NominalText(
                    amount: transaction.amount,
                    prefix: (transaction.isSystem && transaction.title.lowercased().contains("alokasi")) ? "" : (transaction.isExpense ? "-" : "+"),
                    size: 15,
                    color: transaction.isSystem ? Color.indigo.opacity(0.9) : (transaction.isExpense ? .white : Theme.income)
                )
                
                if transaction.syncStatus != "synced" {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        Text("PENDING")
                    }
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(Theme.textSecondary.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            ZStack {
                Color.white.opacity(transaction.isSystem ? 0.04 : 0.02)
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                (transaction.isSystem ? Color.indigo.opacity(0.3) : .white.opacity(0.1)),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
        .cornerRadius(20)
        .shadow(color: transaction.isSystem ? Color.indigo.opacity(0.1) : .clear, radius: 10, x: 0, y: 5)
    }
}
