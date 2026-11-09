import SwiftUI

struct Theme {
    // Colors
    static let background = Color(hex: "0F0F0F")
    static let cardBackground = Color(hex: "1C1C1E")
    static let accent = Color(hex: "A8DADC")
    static let primary = Color(hex: "457B9D")
    static let secondary = Color(hex: "1D3557")
    static let expense = Color(hex: "E63946")
    static let income = Color(hex: "2A9D8F")
    static let textMain = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    
    // Gradients
    static let mainGradient = LinearGradient(
        colors: [accent, primary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.15), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "BF953F"), Color(hex: "FCF6BA"), Color(hex: "B38728"), Color(hex: "FBF5B7"), Color(hex: "AA771C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Shadows & Effects
    static let glassShadow = Color.black.opacity(0.3)
    static let glassBorder = Color.white.opacity(0.1)
    
    static func shadow(color: Color = .black.opacity(0.3), radius: CGFloat = 10, x: CGFloat = 0, y: CGFloat = 5) -> some View {
        return EmptyView().shadow(color: color, radius: radius, x: x, y: y)
    }
    
    // Wallet-Specific Gradients
    static func walletGradient(for type: WalletType) -> LinearGradient {
        switch type {
        case .cash:
            return LinearGradient(
                colors: [Color(hex: "2A9D8F"), Color(hex: "264653")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .bank:
            return LinearGradient(
                colors: [Color(hex: "457B9D"), Color(hex: "1D3557")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .eWallet:
            return LinearGradient(
                colors: [Color(hex: "E76F51"), Color(hex: "9C4226")],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }
    
    static func goalGradient(index: Int) -> LinearGradient {
        let colors: [[Color]] = [
            [Color(hex: "1A1A2E"), Color(hex: "16213E")], // Deep Navy
            [Color(hex: "2B2E4A"), Color(hex: "1F2041")], // Slate Slate
            [Color(hex: "082032"), Color(hex: "2C394B")], // Charcoal Blue
            [Color(hex: "191919"), Color(hex: "323232")], // Pure Carbon
            [Color(hex: "1B1B2F"), Color(hex: "4E4E50")], // Dark Metal
            [Color(hex: "121212"), Color(hex: "242424")]  // Midnight
        ]
        let selected = colors[index % colors.count]
        return LinearGradient(colors: selected, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static func walletAccent(for type: WalletType) -> Color {
        switch type {
        case .cash: return Color(hex: "2A9D8F")
        case .bank: return Color(hex: "457B9D")
        case .eWallet: return Color(hex: "E76F51")
        }
    }
    
    static let goldAccent = Color(hex: "FFD700")
    
    // Modern Dynamic Background
    struct DynamicBackground: View {
        var body: some View {
            ZStack {
                Theme.background
                
                // Animated-style mesh blobs
                Circle()
                    .fill(Theme.primary.opacity(0.15))
                    .frame(width: 400, height: 400)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)
                
                Circle()
                    .fill(Theme.accent.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: 100, y: 150)
                
                Circle()
                    .fill(Theme.secondary.opacity(0.2))
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: 50, y: -50)
            }
            .ignoresSafeArea()
        }
    }
    
    // Universal Logo Loader
    @ViewBuilder
    static func logoImage(size: CGFloat) -> some View {
        #if WIDGET_EXTENSION
        // Widgets should use SF Symbols to stay lightweight and avoid archival failures
        ZStack {
            Image(systemName: "wallet.pass.fill")
                .font(.system(size: size * 0.8))
                .foregroundStyle(Theme.mainGradient)
        }
        .frame(width: size, height: size)
        #else
        // Now that "logo" is officially in Assets.xcassets, we can simplify
        if UIImage(named: "logo") != nil {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else if UIImage(named: "wallect-logo") != nil {
            Image("wallect-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            // High-Fidelity Fallback
            ZStack {
                Circle()
                    .fill(Theme.mainGradient)
                    .frame(width: size * 1.4)
                    .blur(radius: size * 0.2)
                    .opacity(0.15)
                
                Image(systemName: "wallet.pass.fill")
                    .font(.system(size: size * 0.8))
                    .foregroundStyle(Theme.mainGradient)
            }
            .frame(width: size, height: size)
        }
        #endif
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    var isLight: Bool {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let brightness = (r * 299 + g * 587 + b * 114) / 1000
        return brightness > 0.7
    }
}
