import SwiftUI

struct WidgetBalanceCard: View {
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
    let showStats: Bool
    
    var body: some View {
        ZStack {
            // Minimalist Deep Background
            LinearGradient(
                colors: [Color(hex: "0B0B0B"), Color(hex: "1A1A1A")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle Depth Circle (No Blurs for Max Stability)
            Theme.mainGradient.opacity(0.12)
                .clipShape(Circle())
                .frame(width: 260, height: 260)
                .offset(x: -80, y: -90)

            VStack(alignment: .leading, spacing: 20) {
                Spacer(minLength: 0)
                
                // Main Balance Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("TOTAL SALDO")
                        .font(.custom("Inter-Bold", size: 9))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1.2)
                    
                    NominalText(amount: totalBalance, size: 28)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                
                if showStats {
                    // Refined Stats Row
                    HStack(spacing: 0) {
                        statItem(label: "MASUK", amount: monthlyIncome, color: Theme.income)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 1, height: 18)
                            .padding(.horizontal, 15)
                        
                        statItem(label: "KELUAR", amount: monthlyExpense, color: Theme.expense)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func statItem(label: String, amount: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 7, weight: .black))
                .foregroundColor(Color.white.opacity(0.3))
            
            NominalText(amount: amount, size: 11, color: .white)
        }
    }
}
