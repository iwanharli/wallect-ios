import SwiftUI
import SwiftData

struct TransactionRow: View {
    let transaction: Transaction
    @Query var categories: [Category]
    
    private var categoryIcon: String {
        categories.first(where: { $0.name == transaction.category })?.icon ?? "dollarsign.circle"
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(Theme.cardBackground)
                    .frame(width: 48, height: 48)
                
                Image(systemName: categoryIcon)
                    .font(.system(size: 18))
                    .foregroundColor(transaction.isExpense ? Theme.expense.opacity(0.8) : Theme.income.opacity(0.8))
            }
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.textMain)
                
                Text(transaction.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.isExpense ? "-\(CurrencyFormatter.format(transaction.amount))" : "+\(CurrencyFormatter.format(transaction.amount))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(transaction.isExpense ? Theme.expense : Theme.income)
                
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 10))
                    .foregroundColor(Theme.textSecondary.opacity(0.6))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.cardBackground.opacity(0.4))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.03), lineWidth: 0.5)
        )
    }
}
