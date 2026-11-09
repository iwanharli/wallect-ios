import SwiftUI
import LocalAuthentication

struct BiometricLockView: View {
    @ObservedObject var authManager = AppAuthManager.shared
    @State private var appeared = false
    @State private var ringRotation: Double = 0
    @State private var animateMesh = false
    
    var body: some View {
        ZStack {
            // Background Animated Mesh (Consistent with Brand)
            ZStack {
                Theme.background.ignoresSafeArea()
                
                Circle()
                    .fill(Theme.primary.opacity(0.15))
                    .frame(width: 450, height: 450)
                    .blur(radius: 90)
                    .offset(x: animateMesh ? 100 : -100, y: animateMesh ? -150 : -200)
                
                Circle()
                    .fill(Theme.accent.opacity(0.12))
                    .frame(width: 380, height: 380)
                    .blur(radius: 80)
                    .offset(x: animateMesh ? -80 : 80, y: animateMesh ? 150 : 200)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Cyber Logo with Rings
                ZStack {
                    // Counter-Rotating Orbital Rings
                    ZStack {
                        Circle()
                            .stroke(Theme.accent.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [2, 12]))
                            .frame(width: 165, height: 165)
                            .rotationEffect(.degrees(ringRotation))
                        
                        Circle()
                            .stroke(Theme.accent.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 16]))
                            .frame(width: 145, height: 145)
                            .rotationEffect(.degrees(-ringRotation * 1.5))
                    }
                    
                    Theme.logoImage(size: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .shadow(color: Theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                }
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                
                VStack(spacing: 12) {
                    Text("Wallect Terkunci")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Verifikasi identitas Kamu untuk melanjutkan")
                        .font(.subheadline)
                        .foregroundColor(Theme.textSecondary)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                
                // Unlock Trigger Button
                Button(action: {
                    HapticManager.shared.impact(.medium)
                    Task {
                        await authManager.unlockWithBiometrics()
                    }
                }) {
                    HStack(spacing: 15) {
                        Image(systemName: BiometricAuthService.shared.biometricType == .faceID ? "faceid" : "touchid")
                            .font(.title2)
                        
                        Text(BiometricAuthService.shared.biometricType == .faceID ? "Buka dengan Face ID" : "Buka dengan Touch ID")
                            .font(.headline.bold())
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(Theme.accent)
                    .cornerRadius(20)
                    .padding(.horizontal, 40)
                    .shadow(color: Theme.accent.opacity(0.4), radius: 15, x: 0, y: 8)
                }
                .padding(.bottom, 50)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 40)
            }
        }
        .onAppear {
            setupAnimations()
            // Auto-trigger authentication
            Task {
                await authManager.unlockWithBiometrics()
            }
        }
    }
    
    private func setupAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            appeared = true
        }
        
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            animateMesh.toggle()
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
    }
}

#Preview {
    BiometricLockView()
}
