import SwiftUI
import Combine
import AuthenticationServices
#if canImport(GoogleSignIn)
import GoogleSignIn
import GoogleSignInSwift
#endif

class AppAuthManager: ObservableObject {
    static let shared = AppAuthManager()
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserDTO?
    @Published var profileImage: UIImage?
    
    // Biometric Lock States
    @Published var isLocked: Bool = false
    @AppStorage("isBiometricEnabled") var isBiometricEnabled: Bool = false
    
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
            
            // Set initial lock state
            if isBiometricEnabled {
                self.isLocked = true
            }
            
            // Load cached user
            if let userData = UserDefaults.standard.data(forKey: userKey),
               let cachedUser = try? JSONDecoder().decode(UserDTO.self, from: userData) {
                self.currentUser = cachedUser
            }
            
            // Fetch fresh profile from backend
            Task {
                await fetchUserProfile()
                await MainActor.run {
                    self.loadLocalProfileImage()
                }
            }
            
            #if canImport(GoogleSignIn)
            // Try to restore Google session in background
            GIDSignIn.sharedInstance.restorePreviousSignIn { _, _ in }
            #endif
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
        
        await MainActor.run {
            self.currentUser = authResponse.user
            self.isAuthenticated = true
            self.loadLocalProfileImage()
        }
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
        
        await MainActor.run {
            self.currentUser = authResponse.user
            self.isAuthenticated = true
            self.loadLocalProfileImage()
        }
    }
    
    func logout() {
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userKey)
        self.isAuthenticated = false
        self.currentUser = nil
        self.profileImage = nil
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    private func saveUser(_ user: UserDTO) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userKey)
        }
    }
    
    // MARK: - Local Profile Image Persistence
    private func profileImageName(for userId: String) -> String {
        return "user_profile_\(userId).jpg"
    }
    
    func saveLocalProfileImage(data: Data) {
        guard let userId = currentUser?.id else { return }
        guard let url = getDocumentsDirectory()?.appendingPathComponent(profileImageName(for: userId)) else { return }
        
        do {
            try data.write(to: url)
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        } catch {
            print("Error saving local profile image: \(error.localizedDescription)")
        }
    }
    
    private func loadLocalProfileImage() {
        guard let userId = currentUser?.id else { 
            self.profileImage = nil
            return 
        }
        guard let url = getDocumentsDirectory()?.appendingPathComponent(profileImageName(for: userId)) else { return }
        
        if FileManager.default.fileExists(atPath: url.path),
           let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            self.profileImage = image
        } else {
            self.profileImage = nil
        }
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    // MARK: - Biometric Actions
    
    @MainActor
    func unlockWithBiometrics() async {
        let success = await BiometricAuthService.shared.authenticate(reason: "Buka kunci Wallect Kamu")
        if success {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.isLocked = false
            }
        }
    }
    
    func lockApp() {
        if isBiometricEnabled && isAuthenticated {
            self.isLocked = true
        }
    }
}
