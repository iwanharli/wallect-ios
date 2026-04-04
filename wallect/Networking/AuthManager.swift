import SwiftUI
import Combine
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift

class AppAuthManager: ObservableObject {
    static let shared = AppAuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserDTO?
    
    // Real Google Client ID
    static let googleClientID = "380422483162-4gvspvvmsc0sacmvc2u8e5srkpdnmrul.apps.googleusercontent.com"
    
    private let tokenKey = "auth_token"
    private let userKey = "auth_user"
    
    init() {
        checkAuthState()
    }
    
    func checkAuthState() {
        if UserDefaults.standard.string(forKey: tokenKey) != nil {
            self.isAuthenticated = true
            
            // Load cached user
            if let userData = UserDefaults.standard.data(forKey: userKey),
               let cachedUser = try? JSONDecoder().decode(UserDTO.self, from: userData) {
                self.currentUser = cachedUser
            }
            
            // Fetch fresh profile from backend
            Task {
                await fetchUserProfile()
            }
            
            // Try to restore Google session in background
            GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in }
        }
    }
    
    func fetchUserProfile() async {
        do {
            let user: UserDTO = try await APIClient.shared.request(endpoint: "auth/me")
            await MainActor.run {
                self.currentUser = user
                self.saveUser(user)
                print("Profile synchronized with database: \(user.name ?? "No Name")")
            }
        } catch {
            print("Failed to fetch user profile: \(error)")
        }
    }
    
    func loginWithGoogle(idToken: String, email: String, name: String, googleId: String) async throws {
        // Construct Login Request
        struct GoogleLoginRequest: Codable {
            let idToken: String
            let email: String
            let name: String
            let googleId: String
        }
        
        let requestBody = GoogleLoginRequest(idToken: idToken, email: email, name: name, googleId: googleId)
        
        // Call Backend
        let authResponse: AuthResponse = try await APIClient.shared.request(
            endpoint: "auth/google",
            method: .post,
            body: requestBody
        )
        
        // Save Token
        saveToken(authResponse.token)
        saveUser(authResponse.user)
        self.currentUser = authResponse.user
        self.isAuthenticated = true
    }
    
    func loginWithApple(identityToken: String, email: String, name: String, appleId: String) async throws {
        struct AppleLoginRequest: Codable {
            let identityToken: String
            let email: String
            let name: String
            let appleId: String
        }
        
        let requestBody = AppleLoginRequest(identityToken: identityToken, email: email, name: name, appleId: appleId)
        
        // Call Backend
        let authResponse: AuthResponse = try await APIClient.shared.request(
            endpoint: "auth/apple",
            method: .post,
            body: requestBody
        )
        
        // Save Token
        saveToken(authResponse.token)
        saveUser(authResponse.user)
        self.currentUser = authResponse.user
        self.isAuthenticated = true
    }
    
    func logout() {
        GIDSignIn.sharedInstance.signOut()
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.isAuthenticated = false
        self.currentUser = nil
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    private func saveUser(_ user: UserDTO) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
}
