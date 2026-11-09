import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {}
    
    /// Prepare generators to reduce latency
    func prepare() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
            lightGenerator.prepare()
        case .medium:
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare()
        case .heavy:
            heavyGenerator.impactOccurred()
            heavyGenerator.prepare()
        case .soft:
            lightGenerator.impactOccurred()
            lightGenerator.prepare()
        case .rigid:
            heavyGenerator.impactOccurred()
            heavyGenerator.prepare()
        @unknown default:
            mediumGenerator.impactOccurred()
        }
    }
    
    func selection() {
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare()
    }
}
