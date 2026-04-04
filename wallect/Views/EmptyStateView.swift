import SwiftUI

struct EmptyStateView: View {
    let action: () -> Void
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Theme.cardBackground.opacity(0.4))
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulse ? 1.1 : 1.0)
                    .opacity(pulse ? 0.3 : 0.6)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.textSecondary)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
            
            VStack(spacing: 8) {
                Text("Belum ada transaksi")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Theme.textMain)
                
                Text("Tap tombol + untuk mulai mencatat keuangan Anda, atau buat data contoh di bawah.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: action) {
                Text("Buat Data Contoh")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Theme.accent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.accent.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.top, 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}
