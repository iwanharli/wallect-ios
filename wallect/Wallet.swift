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
    
    @Relationship(deleteRule: .nullify, inverse: \Transaction.wallet)
    var transactions: [Transaction]?
    
    init(id: String = UUID().uuidString, name: String, type: WalletType, initialBalance: Double = 0) {
        self.id = id
        self.name = name
        self.type = type.rawValue
        self.icon = type.icon
        self.initialBalance = initialBalance
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
            initialBalance: initialBalance
        )
    }
}
