import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case analytics = "chart.pie.fill"
    case add = "plus" // Special central tab
    case wallets = "creditcard.fill"
    case settings = "gearshape.fill"
    
    var title: String {
        switch self {
        case .home: return "Beranda"
        case .analytics: return "Analisis"
        case .add: return ""
        case .wallets: return "Dompet"
        case .settings: return "Pengaturan"
        }
    }
}
