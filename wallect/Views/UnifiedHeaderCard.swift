import SwiftUI

struct UnifiedHeaderCard: View {
    let userName: String
    let totalBalance: Double
    let monthlyIncome: Double
    let monthlyExpense: Double
    let profileAction: () -> Void
    let incomeAction: () -> Void
    let expenseAction: () -> Void
    
    @State private var isBreathing = false
    @State private var borderPhase: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Spacer for floating logo badge
            Color.clear.frame(height: 5)
            
            // Top Row: App Logo & User Identity
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Halluuw,")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(Color.white.opacity(0.4))
                        .tracking(1.5)
                    Text(userName)
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Premium Profile Button
                Button(action: profileAction) {
                    profileImageContainer
                }
            }
            .padding(.horizontal, 4)
            
            // Hero Section: Impactful Balance Display
            VStack(spacing: 8) {
                
                NominalText(amount: totalBalance, size: 36, shadow: .black.opacity(0.3), minScale: 0.7)
            }
            .padding(.top, 10)
            .padding(.bottom, 2)
            
            // Floating Stats Card: Modern Neat Breakdown
            HStack(spacing: 0) {
                statBox(
                    label: "PEMASUKAN",
                    subLabel: "BULAN INI",
                    amount: monthlyIncome,
                    color: Theme.income,
                    icon: "arrow.down.left",
                    action: incomeAction
                )
                
                // Vertical Glass Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.1), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 1, height: 40)
                    .padding(.horizontal, 15)
                
                statBox(
                    label: "PENGELUARAN",
                    subLabel: "BULAN INI",
                    amount: monthlyExpense,
                    color: .white,
                    icon: "arrow.up.right",
                    action: expenseAction
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.03))
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.15), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .padding(.horizontal, 5)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 15)
        .background(
            meshBackground
        )
        .overlay(
            ZStack {
                // Main Static Border
                RoundedRectangle(cornerRadius: 35)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                
                // Animated Racing Glow (Primary Pulse)
                RoundedRectangle(cornerRadius: 35)
                    .trim(from: borderPhase, to: borderPhase + 0.1)
                    .stroke(
                        LinearGradient(
                            colors: [.clear, Theme.accent, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .blur(radius: 2)
                    .opacity(borderPhase > 0.9 ? 0 : 1) // Clean loop
                
                // Animated Racing Glow (Secondary Pulse)
                RoundedRectangle(cornerRadius: 35)
                    .trim(from: borderPhase - 0.5, to: (borderPhase - 0.5) + 0.1)
                    .stroke(
                        LinearGradient(
                            colors: [.clear, Theme.accent.opacity(0.6), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .blur(radius: 2)
                    .opacity(borderPhase < 0.5 ? 0 : 1) // Clean loop
            }
        )
        .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 20)
        .overlay(
            logoBadge,
            alignment: .top
        )
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                borderPhase = 1.0
            }
        }
    }
    
    // MARK: - Subcomponents
    
    private var logoBadge: some View {
        ZStack {
            // Shadow Glow
            Circle()
                .fill(Theme.accent.opacity(0.2))
                .frame(width: 60, height: 60)
                .blur(radius: 15)
                .scaleEffect(isBreathing ? 1.3 : 0.8)
            
            // Background Container
            Circle()
                .fill(Color(hex: "0B0B0B"))
                .frame(width: 60, height: 60)
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
            
            Theme.logoImage(size: 32)
                .scaleEffect(isBreathing ? 1.1 : 0.95)
        }
        .offset(y: -30)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }
    private var profileImageContainer: some View {
        ProfileImageView(size: 44)
    }
    
    private var meshBackground: some View {
        ZStack {
            // Base Deep Layer
            RoundedRectangle(cornerRadius: 35)
                .fill(Color(hex: "0B0B0B"))
            
            // Vibrant Mesh Blobs
            Group {
                // Top-Left: Indigo/Purple
                Circle()
                    .fill(Color.indigo.opacity(0.4))
                    .frame(width: 250, height: 250)
                    .blur(radius: 60)
                    .offset(x: -120, y: -100)
                
                // Bottom-Right: Cyan/Teal
                Circle()
                    .fill(Color.cyan.opacity(0.35))
                    .frame(width: 220, height: 220)
                    .blur(radius: 70)
                    .offset(x: 100, y: 100)
                
                // Bottom-Left: Pink/Magenta (Accent)
                Circle()
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 50)
                    .offset(x: -80, y: 120)
            }
            .allowsHitTesting(false)
            
            // Glass Material
            RoundedRectangle(cornerRadius: 35)
                .fill(.ultraThinMaterial.opacity(0.15))
        }
    }
    
    private func statBox(label: String, subLabel: String, amount: Double, color: Color, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(color)
                    
                    Text(label)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(Color.white.opacity(0.4))
                        .tracking(1.5)
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    NominalText(amount: amount, size: 14)
                    
                    Text(subLabel)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color.white.opacity(0.2))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
