import Foundation
import SwiftData

@Model
final class Category {
    var id: String
    var name: String
    var icon: String
    var isExpense: Bool
    var hexColor: String = "A8DADC"
    var syncStatus: String = "synced"
    
    init(id: String = UUID().uuidString, name: String, icon: String, hexColor: String = "A8DADC", isExpense: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.hexColor = hexColor
        self.isExpense = isExpense
    }

    func toDTO() -> CategoryDTO {
        CategoryDTO(
            id: id,
            name: name,
            icon: icon,
            hexColor: hexColor,
            isExpense: isExpense
        )
    }
}
