import Foundation
import SwiftData

enum WalletType: String, Codable, CaseIterable {
    case cash = "Dompet"
    case bank = "Bank"
    case eWallet = "E-wallet"
    
    var icon: String {
        switch self {
        case .cash: return "banknote"
        case .bank: return "building.columns.fill"
        case .eWallet: return "iphone.rear.camera"
        }
    }
}

@Model
final class Wallet {
    var id: String
    var name: String
    var type: String // Store raw value of WalletType
    var icon: String
    var initialBalance: Double
    var syncStatus: String = "synced"
    var isArchived: Bool = false
    
    // Smart Target Goal Fields
    var isGoal: Bool = false
    var targetAmount: Double?
    var startDate: Date?
    var endDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.wallet)
    var transactions: [Transaction]?
    
    init(id: String = UUID().uuidString, name: String, type: WalletType, initialBalance: Double = 0, isGoal: Bool = false, targetAmount: Double? = nil, startDate: Date? = nil, endDate: Date? = nil, isArchived: Bool = false) {
        self.id = id
        self.name = name
        self.type = type.rawValue
        self.icon = type.icon
        self.initialBalance = initialBalance
        self.isGoal = isGoal
        self.targetAmount = targetAmount
        self.startDate = startDate
        self.endDate = endDate
        self.isArchived = isArchived
        self.transactions = []
    }
    
    var walletType: WalletType {
        WalletType(rawValue: type) ?? .cash
    }
    
    func toDTO() -> WalletDTO {
        WalletDTO(
            id: id,
            name: name,
            type: type,
            icon: icon,
            initialBalance: initialBalance,
            isGoal: isGoal,
            targetAmount: targetAmount,
            startDate: startDate,
            endDate: endDate,
            isArchived: isArchived
        )
    }

    var currentBalance: Double {
        let txs = transactions ?? []
        let income = txs.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
        let expense = txs.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
        return initialBalance + income - expense
    }
    
    // Total income/savings collected, ignoring any "Pengembalian" or automated reversal transactions
    var totalSaved: Double {
        let txs = transactions ?? []
        // Filter out reversal transactions to preserve the 'achieved' amount display
        let savingsIn = txs.filter { tx in 
            !tx.isExpense && !tx.title.contains("Pengembalian") 
        }.reduce(0) { $0 + $1.amount }
        return initialBalance + savingsIn
    }
    
    var isAchieved: Bool {
        guard let target = targetAmount, target > 0 else { return false }
        return totalSaved >= target
    }
}
