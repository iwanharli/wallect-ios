import Foundation
import SwiftData

@Model
final class Budget {
    var id: String
    var category: String
    var limit: Double
    var isRecurring: Bool = false
    var startDate: Date?
    var endDate: Date?
    var syncStatus: String
    
    init(id: String = UUID().uuidString, category: String, limit: Double, isRecurring: Bool = false, startDate: Date = Date.now, endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date.now, syncStatus: String = "synced") {
        self.id = id
        self.category = category
        self.limit = limit
        self.isRecurring = isRecurring
        self.startDate = startDate
        self.endDate = endDate
        self.syncStatus = syncStatus
    }

    var isActive: Bool {
        if isRecurring { return true }
        guard let endDate = endDate else { return true }
        return endDate >= Date.now
    }

    func toDTO() -> BudgetDTO {
        BudgetDTO(
            id: id,
            category: category,
            limit: limit,
            isRecurring: isRecurring,
            startDate: startDate ?? Date.now,
            endDate: endDate ?? (Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date.now)
        )
    }
}
