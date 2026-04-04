import Foundation
import SwiftData

@Model
final class Category {
    var id: String
    var name: String
    var icon: String
    var isExpense: Bool
    var syncStatus: String = "synced"
    
    init(id: String = UUID().uuidString, name: String, icon: String, isExpense: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isExpense = isExpense
    }

    func toDTO() -> CategoryDTO {
        CategoryDTO(
            id: id,
            name: name,
            icon: icon,
            isExpense: isExpense
        )
    }
}
