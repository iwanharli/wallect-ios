import Foundation
import SwiftData

class PersistenceService {
    static let shared = PersistenceService()
    
    @MainActor
    func clearAllData(context: ModelContext) {
        print("DEBUG: [PersistenceService] clearAllData called! This will delete EVERY record (budgets, wallets, transactions).")
        // Get call stack or at least log the trigger if possible? Not easy in Swift.
        
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
            print("Local data cleared successfully (Budgets, Wallets, Transactions, SyncOps).")
        } catch {
            print("Failed to clear local data: \(error)")
        }
    }
}
