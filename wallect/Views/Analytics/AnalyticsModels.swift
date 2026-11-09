import Foundation
import SwiftUI

struct CategoryStat: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct MonthlyStat: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}
