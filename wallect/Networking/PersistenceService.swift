import Foundation
import SwiftData

class PersistenceService {
    static let shared = PersistenceService()
    
    @MainActor
    func clearAllData(context: ModelContext) {
        do {
            // Delete all transactions
            try context.delete(model: Transaction.self)
            
            // Delete all wallets
            try context.delete(model: Wallet.self)
            
            // Delete all categories
            try context.delete(model: Category.self)
            
            // Delete all budgets
            try context.delete(model: Budget.self)
            
            // Delete all sync operations
            try context.delete(model: SyncOperation.self)
            
            try context.save()
            print("Local data cleared successfully.")
        } catch {
            print("Failed to clear local data: \(error)")
        }
    }
}
