import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var authManager = AppAuthManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appeared = false
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo & Title
                VStack(spacing: 20) {
                    Circle()
                        .fill(Theme.mainGradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                        .scaleEffect(appeared ? 1 : 0.5)
                        .opacity(appeared ? 1 : 0)
                    
                    VStack(spacing: 8) {
                        Text("Wallect")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(Theme.textMain)
                        
                        Text("Kelola Keuangan Anda dengan Gaya")
                            .font(.subheadline)
                            .foregroundColor(Theme.textSecondary)
                    }
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                }
                
                Spacer()
                
                // Auth Buttons
                VStack(spacing: 16) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 55)
                    .cornerRadius(15)
                    .padding(.horizontal, 30)
                    
                    Button(action: handleGoogleSignIn) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Sign in with Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                    }
                    .padding(.horizontal, 30)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 40)
                
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Theme.expense)
                        .padding(.top, 10)
                }
                
                Text("Dengan masuk, Anda menyetujui Ketentuan Layanan kami.")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .padding(.bottom, 30)
                    .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                appeared = true
            }
        }
        .overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
            }
        )
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                let identityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)!
                
                isLoading = true
                Task {
                    do {
                        try await authManager.loginWithApple(
                            identityToken: identityToken,
                            email: email ?? "apple_user@example.com",
                            name: "\(fullName?.givenName ?? "User")",
                            appleId: userIdentifier
                        )
                    } catch {
                        errorMessage = "Apple Login Gagal: \(error.localizedDescription)"
                    }
                    isLoading = false
                }
            }
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
    
    private func handleGoogleSignIn() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            errorMessage = "Internal Error: Reference missing"
            return
        }
        
        let config = GIDConfiguration(clientID: AppAuthManager.googleClientID)
        GIDSignIn.sharedInstance.configuration = config
        
        isLoading = true
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Google Login Gagal: \(error.localizedDescription)"
                    return
                }
                
                guard let result = result else { return }
                let user = result.user
                
                Task {
                    do {
                        try await self.authManager.loginWithGoogle(
                            idToken: user.idToken?.tokenString ?? "",
                            email: user.profile?.email ?? "",
                            name: user.profile?.name ?? "Google User",
                            googleId: user.userID ?? ""
                        )
                    } catch {
                        Task { @MainActor in
                            self.errorMessage = "Server Sync Gagal: \(error.localizedDescription)"
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
