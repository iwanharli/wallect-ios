import Foundation
import SwiftData

@Model
final class Budget {
    var id: String
    var category: String
    var limit: Double
    var syncStatus: String = "synced"
    
    init(id: String = UUID().uuidString, category: String, limit: Double) {
        self.id = id
        self.category = category
        self.limit = limit
    }

    func toDTO() -> BudgetDTO {
        BudgetDTO(
            id: id,
            category: category,
            limit: limit
        )
    }
}
