import Foundation
import SwiftData

@Model
final class Transaction {
    var id: String
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var note: String
    var isExpense: Bool
    var wallet: Wallet?
    var syncStatus: String = "synced"
    
    init(id: String = UUID().uuidString, title: String, amount: Double, category: String, date: Date = .now, note: String = "", isExpense: Bool = true, wallet: Wallet? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isExpense = isExpense
        self.wallet = wallet
    }
    
    func toDTO() -> TransactionDTO {
        TransactionDTO(
            id: id,
            title: title,
            amount: amount,
            category: category,
            date: date,
            note: note,
            isExpense: isExpense,
            walletId: wallet?.id
        )
    }
}

