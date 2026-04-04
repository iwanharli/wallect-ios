import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct wallectApp: App {
    @StateObject private var authManager = AppAuthManager.shared
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if authManager.isAuthenticated {
                    ContentView()
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(for: [Transaction.self, Budget.self, Wallet.self, Category.self, SyncOperation.self])
    }
}
