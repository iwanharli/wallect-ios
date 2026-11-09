import SwiftUI

/// NominalText: The single source of truth for all currency displays in the application.
/// Ensures 100% consistency in font (Rounded), weight (Black), and formatting (Monospaced).
struct NominalText: View {
    var amount: Double
    var prefix: String = ""
    var size: CGFloat = 15
    var color: Color = .white
    var weight: Font.Weight = .black
    var isCurrency: Bool = true
    var shadow: Color = .clear
    var minScale: CGFloat = 0.6
    
    var body: some View {
        let textContent: String = {
            if isCurrency {
                return "\(prefix)\(CurrencyFormatter.format(amount))"
            } else {
                return "\(prefix)\(Int(amount))"
            }
        }()
        
        Text(textContent)
            .font(.system(size: size, weight: weight, design: .rounded))
            .foregroundColor(color)
            .shadow(color: shadow, radius: 15, x: 0, y: 10)
            .monospacedDigit()
            .minimumScaleFactor(minScale)
            .lineLimit(1)
    }
}

// Extension for easier usage
extension View {
    func nominalStyle(size: CGFloat = 15, color: Color = .white, weight: Font.Weight = .black) -> some View {
        self.font(.system(size: size, weight: weight, design: .rounded))
            .foregroundColor(color)
            .monospacedDigit()
    }
}
