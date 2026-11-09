import Foundation
import LocalAuthentication

class BiometricAuthService {
    static let shared = BiometricAuthService()
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .touchID: return .touchID
        case .faceID: return .faceID
        default: return .none
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    func authenticate(reason: String) async -> Bool {
        let context = LAContext()
        
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
        } catch {
            print("Biometric authentication failed: \(error.localizedDescription)")
            return false
        }
    }
}
