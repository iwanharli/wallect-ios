import Foundation
import SwiftData

class WalletService {
    static let shared = WalletService()
    
    private let apiClient = APIClient.shared
    private let syncManager = SyncManager.shared
    
    func createWallet(_ wallet: Wallet, context: ModelContext) {
        context.insert(wallet)
        wallet.syncStatus = "pending"
        
        let dto = wallet.toDTO()
        syncManager.enqueue(endpoint: "wallets", method: .post, body: dto, context: context)
    }
    
    func updateWallet(_ wallet: Wallet, context: ModelContext) {
        wallet.syncStatus = "pending"
        
        let dto = wallet.toDTO()
        syncManager.enqueue(endpoint: "wallets/\(wallet.id)", method: .put, body: dto, context: context)
    }
    
    func deleteWallet(_ wallet: Wallet, context: ModelContext) {
        let id = wallet.id
        context.delete(wallet)
        
        syncManager.enqueue(endpoint: "wallets/\(id)", method: .delete, context: context)
    }
}
