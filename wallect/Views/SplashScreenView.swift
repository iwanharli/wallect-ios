import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var textVisibility: Double = 0.0
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Logo Animation
                ZStack {
                    Circle()
                        .fill(Theme.mainGradient)
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .opacity(0.3)
                    
                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Theme.mainGradient)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Branding Animation
                VStack(spacing: 8) {
                    Text("Wallect")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .tracking(2)
                        .foregroundStyle(.white)
                    
                    Text("Smart Finance Companion")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .tracking(1)
                        .foregroundColor(Theme.textSecondary)
                }
                .opacity(textVisibility)
                .offset(y: textVisibility == 1.0 ? 0 : 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                textVisibility = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
