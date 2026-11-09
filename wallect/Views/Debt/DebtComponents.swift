import SwiftUI

struct DebtSummarySection: View {
    let totalHutang: Double
    let totalPiutang: Double
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Pinjam & Meminjam")
                    .font(.headline)
                    .foregroundColor(Theme.textMain)
                Spacer()
                Button(action: action) {
                    Text("Kelola")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(Theme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.accent.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 15) {
                // Hutang Card (User owes money)
                DebtHorizontalCard(
                    title: "Saya Pinjam",
                    amount: totalHutang,
                    icon: "arrow.down.forward.circle.fill",
                    color: Theme.expense
                )
                
                // Piutang Card (User is owed money)
                DebtHorizontalCard(
                    title: "Saya Meminjamkan",
                    amount: totalPiutang,
                    icon: "arrow.up.right.circle.fill",
                    color: Theme.income
                )
            }
            .padding(.horizontal)
        }
    }
}

struct DebtHorizontalCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                NominalText(amount: amount, size: 16, color: .white)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.cardBackground.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct DebtRow: View {
    let debt: Debt
    
    var body: some View {
        HStack(spacing: 15) {
            // Type Icon
            ZStack {
                Circle()
                    .fill(debt.isDebt ? Theme.expense.opacity(0.15) : Theme.income.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: debt.isDebt ? "arrow.down.forward.circle.fill" : "arrow.up.right.circle.fill")
                    .foregroundColor(debt.isDebt ? Theme.expense : Theme.income)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(debt.title)
                    .font(.headline)
                    .foregroundColor(Theme.textMain)
                
                HStack(spacing: 4) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary)
                    Text(debt.personName)
                        .font(.caption.bold())
                        .foregroundColor(Theme.textSecondary)
                    
                    if let dueDate = debt.dueDate {
                        Text("•")
                            .foregroundColor(Theme.textSecondary.opacity(0.3))
                        Text(dueDate, style: .date)
                            .font(.system(size: 10))
                            .foregroundColor(dueDate < .now && !debt.isPaid ? .red : Theme.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                NominalText(amount: debt.amount, size: 16, color: debt.isPaid ? Theme.textSecondary : (debt.isDebt ? Theme.expense : Theme.income))
                
                if debt.isPaid {
                    Text("LUNAS")
                        .font(.system(size: 8, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.income.opacity(0.2))
                        .foregroundColor(Theme.income)
                        .cornerRadius(4)
                } else if let dueDate = debt.dueDate, dueDate < .now {
                    Text("MENUNGGAK")
                        .font(.system(size: 8, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.expense.opacity(0.2))
                        .foregroundColor(Theme.expense)
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Theme.cardBackground.opacity(0.3))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}
