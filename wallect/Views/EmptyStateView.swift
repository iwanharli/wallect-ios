import SwiftUI

struct EmptyStateView: View {
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
                
                Text("Tap tombol + untuk mulai mencatat keuangan Kamu.")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
}
