import Foundation
import SwiftData

@Model
final class Debt {
    var id: String
    var title: String
    var amount: Double
    var personName: String
    var isDebt: Bool // true: Hutang (user owes), false: Piutang (user is owed)
    var dueDate: Date?
    var isPaid: Bool
    var dateAdded: Date
    var note: String
    var syncStatus: String = "synced"
    
    init(
        id: String = UUID().uuidString,
        title: String,
        amount: Double,
        personName: String,
        isDebt: Bool = true,
        dueDate: Date? = nil,
        isPaid: Bool = false,
        dateAdded: Date = .now,
        note: String = "",
        syncStatus: String = "pending"
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.personName = personName
        self.isDebt = isDebt
        self.dueDate = dueDate
        self.isPaid = isPaid
        self.dateAdded = dateAdded
        self.note = note
        self.syncStatus = syncStatus
    }

    func toDTO() -> DebtDTO {
        return DebtDTO(
            id: id,
            title: title,
            amount: amount,
            personName: personName,
            isDebt: isDebt,
            dueDate: dueDate,
            isPaid: isPaid,
            note: note
        )
    }
}
