import SwiftUI
import Combine

class NavigationState: ObservableObject {
    @Published var isTabBarHidden: Bool = false
    
    // Static shared instance for easy access if needed outside environment
    static let shared = NavigationState()
}
