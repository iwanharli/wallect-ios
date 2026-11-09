import SwiftUI
import SwiftData
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
struct wallectApp: App {
    @StateObject private var authManager = AppAuthManager.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Base background color to prevent black flash
                Color(hex: "080808").ignoresSafeArea()
                
                if authManager.isAuthenticated {
                    if authManager.isLocked && authManager.isBiometricEnabled {
                        BiometricLockView()
                    } else {
                        ContentView()
                    }
                } else {
                    LoginView()
                }
                
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeIn(duration: 0.8)) {
                        showSplash = false
                    }
                }
            }
            .onOpenURL { url in
                #if canImport(GoogleSignIn)
                GIDSignIn.sharedInstance.handle(url)
                #endif
            }
        }
        .modelContainer(DataController.shared.container)
    }
}
