import SwiftUI
#if canImport(GoogleSignIn)
import GoogleSignIn
import GoogleSignInSwift
#endif

struct LoginView: View {
    @StateObject private var authManager = AppAuthManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appeared = false
    
    // Advanced Animation States
    @State private var animateMesh = false
    @State private var ringRotation: Double = 0
    @State private var scanOffset: CGFloat = -0.1
    @State private var showTitle = false
    @State private var showButtons = false
    @State private var isBreathing = false
    
    var body: some View {
        ZStack {
            // Cinematic Background Layers
            animatedMeshBackground
            scanningHorizon
            
            VStack(spacing: 0) {
                Spacer()
                
                // Portal Logo System
                VStack(spacing: -15) {
                    ZStack {
                        // Orbital Rings (Consistent with Splash)
                        ZStack {
                            Circle()
                                .stroke(Theme.accent.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [2, 12]))
                                .frame(width: 145, height: 145)
                                .rotationEffect(.degrees(ringRotation))
                            
                            Circle()
                                .stroke(Theme.accent.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4, 16]))
                                .frame(width: 125, height: 125)
                                .rotationEffect(.degrees(-ringRotation * 1.5))
                        }
                        .opacity(appeared ? 1 : 0)
                        
                        // Subtle Core Glow
                        Circle()
                            .fill(Theme.accent.opacity(0.2))
                            .frame(width: 130, height: 130)
                            .blur(radius: 40)
                            .scaleEffect(isBreathing ? 1.2 : 1.0)
                        
                        // Central Logo Core
                        Theme.logoImage(size: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                            .shadow(color: Theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .scaleEffect(appeared ? 1 : 0.6)
                    .opacity(appeared ? 1 : 0)
                }
                .padding(.bottom, 60)
                
                // Branding & Auth Container
                VStack(spacing: 45) {
                    // Modern Branding
                    VStack(spacing: 12) {
                        Text("Wallect")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .tracking(2)
                            .foregroundColor(.white)
                        
                        Text("FINANCIAL PORTAL")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(4)
                            .foregroundColor(Theme.accent.opacity(0.8))
                    }
                    .opacity(showTitle ? 1 : 0)
                    .offset(y: showTitle ? 0 : 20)
                    
                    // Floating Auth Elements (No Card)
                    VStack(spacing: 25) {
                        Text("Selamat datang kembali. Silakan masuk untuk mengelola aset Anda.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        // Premium Google Sign-In Button
                        Button(action: {
                            HapticManager.shared.impact(.medium)
                            handleGoogleSignIn()
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                                
                                Text("MASUK DENGAN GOOGLE")
                                    .font(.system(size: 13, weight: .black))
                                    .kerning(1)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(LinearGradient(colors: [Theme.accent.opacity(0.4), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 40)
                    }
                    .padding(.horizontal, 24)
                    .opacity(showButtons ? 1 : 0)
                    .offset(y: showButtons ? 0 : 30)
                }
                
                Spacer()
                
                // Footer Content
                VStack(spacing: 12) {
                    Text("Digital Asset Management Platform")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Theme.textSecondary.opacity(0.4))
                        .kerning(1)
                    
                    Text("Dengan masuk, Kamu menyetujui Ketentuan Layanan kami.")
                        .font(.system(size: 10))
                        .foregroundColor(Theme.textSecondary.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }
                .padding(.bottom, 40)
                .opacity(showButtons ? 1 : 0)
            }
            .blur(radius: isLoading ? 5 : 0)
        }
        .onAppear {
            startCinematicSequence()
        }
        .overlay(
            ZStack {
                if isLoading {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        LoadingPulseView()
                        Text("MENGAMANKAN SESI...")
                            .font(.system(size: 10, weight: .black))
                            .kerning(2)
                            .foregroundColor(Theme.accent)
                    }
                }
                
                if let error = errorMessage {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(error)
                        }
                        .font(.system(size: 12, weight: .bold))
                        .padding()
                        .background(Theme.expense.opacity(0.9))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 120)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { errorMessage = nil }
                            }
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Components
    
    private func startCinematicSequence() {
        // 1. Background Layering
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            animateMesh.toggle()
        }
        
        withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        
        withAnimation(.linear(duration: 5).repeatForever(autoreverses: false).delay(1)) {
            scanOffset = 1.2
        }
        
        // 2. Staggered Core Logo
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            appeared = true
        }
        
        // 3. Staggered Title
        withAnimation(.easeOut(duration: 0.8).delay(0.8)) {
            showTitle = true
        }
        
        // 4. Staggered Buttons & Card
        withAnimation(.spring(response: 0.9, dampingFraction: 0.8).delay(1.2)) {
            showButtons = true
        }
        
        // 5. Ambient Breath
        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true).delay(2)) {
            isBreathing = true
        }
    }
    
    private var animatedMeshBackground: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            Circle()
                .fill(Theme.primary.opacity(0.2))
                .frame(width: 450, height: 450)
                .blur(radius: 90)
                .offset(x: animateMesh ? 100 : -100, y: animateMesh ? -150 : -200)
            
            Circle()
                .fill(Theme.accent.opacity(0.15))
                .frame(width: 380, height: 380)
                .blur(radius: 80)
                .offset(x: animateMesh ? -80 : 80, y: animateMesh ? 150 : 200)
        }
    }
    
    private var scanningHorizon: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Theme.accent.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 2)
                .offset(y: scanOffset * geo.size.height)
                .blur(radius: 1)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Navigation Helpers
    
    #if !WIDGET_EXTENSION
    private func getTopMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return nil }
        
        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    #endif

    private func handleGoogleSignIn() {
        #if canImport(GoogleSignIn)
        guard let topVC = getTopMostViewController() else {
            errorMessage = "Reference missing for authentication"
            return
        }
        
        let config = GIDConfiguration(clientID: AppAuthManager.googleClientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Trigger haptic
        HapticManager.shared.impact(.medium)
        
        // 1. We DON'T set isLoading = true here because it can trigger a redraw 
        // that conflicts with the modal presentation in SwiftUI.
        
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { result, error in
            if let error = error {
                // Ignore cancelations to keep UI clean
                if (error as NSError).code != GIDSignInError.canceled.rawValue {
                    self.errorMessage = "Google Login Gagal: \(error.localizedDescription)"
                }
                return
            }
            
            guard let result = result else { return }
            let user = result.user
            
            // 2. NOW we show the loader because we are entering network sync phase
            withAnimation { self.isLoading = true }
            
            Task {
                do {
                    try await self.authManager.loginWithGoogle(
                        idToken: user.idToken?.tokenString ?? "",
                        email: user.profile?.email ?? "",
                        name: user.profile?.name ?? "Google User",
                        googleId: user.userID ?? ""
                    )
                } catch {
                    await MainActor.run {
                        self.isLoading = false
                        self.errorMessage = "Server Sync Gagal: \(error.localizedDescription)"
                    }
                }
            }
        }
        #else
        errorMessage = "Google Sign-In saat ini tidak tersedia (Module missing)."
        #endif
    }
}

struct LoadingPulseView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.accent.opacity(0.2), lineWidth: 2)
                .frame(width: 60, height: 60)
                .scaleEffect(animate ? 1.5 : 1.0)
                .opacity(animate ? 0 : 1)
            
            Circle()
                .fill(Theme.accent)
                .frame(width: 12, height: 12)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}

#Preview {
    LoginView()
}
