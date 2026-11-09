import Foundation
import SwiftData

@MainActor
class TransactionService {
    static let shared = TransactionService()
    
    private let apiClient = APIClient.shared
    private let syncManager = SyncManager.shared
    
    func fetchTransactions(context: ModelContext) async {
        print("DEBUG: [TransactionService] fetchTransactions starting...")
        do {
            let dtos: [TransactionDTO] = try await apiClient.request(endpoint: "transactions")
            print("DEBUG: [TransactionService] Received \(dtos.count) transaction(s) from server.")
            
            // Sync local with remote
            await MainActor.run {
                for dto in dtos {
                    let fetchDescriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.id == dto.id })
                    if let existing = try? context.fetch(fetchDescriptor).first {
                        // Update existing
                        existing.title = dto.title
                        existing.amount = dto.amount
                        existing.category = dto.category
                        existing.date = dto.date
                        existing.note = dto.note ?? ""
                        existing.isExpense = dto.isExpense
                        existing.syncStatus = "synced"
                        
                        // Link wallet
                        if let walletId = dto.walletId {
                            let walletFetch = FetchDescriptor<Wallet>(predicate: #Predicate { $0.id == walletId })
                            existing.wallet = try? context.fetch(walletFetch).first
                        }
                    } else {
                        // Create new
                        let newTx = Transaction(
                            id: dto.id,
                            title: dto.title,
                            amount: dto.amount,
                            category: dto.category,
                            date: dto.date,
                            note: dto.note ?? "",
                            isExpense: dto.isExpense
                        )
                        newTx.syncStatus = "synced"
                        
                        // Link wallet
                        if let walletId = dto.walletId {
                            let walletFetch = FetchDescriptor<Wallet>(predicate: #Predicate { $0.id == walletId })
                            newTx.wallet = try? context.fetch(walletFetch).first
                        }
                        
                        context.insert(newTx)
                    }
                }
                try? context.save()
                print("DEBUG: [TransactionService] fetchTransactions completed and saved.")
            }
        } catch {
            print("DEBUG: [TransactionService] fetchTransactions FAILED: \(error)")
        }
    }
    
    func createTransaction(_ transaction: Transaction, context: ModelContext) {
        context.insert(transaction)
        transaction.syncStatus = "pending"
        
        try? context.save() // Critical: Persist locally first
        
        let dto = transaction.toDTO()
        syncManager.enqueue(endpoint: "transactions", method: .post, body: dto, context: context)
    }

    func updateTransaction(_ transaction: Transaction, context: ModelContext) {
        transaction.syncStatus = "pending"
        
        try? context.save() // Critical: Persist locally first
        
        let dto = transaction.toDTO()
        syncManager.enqueue(endpoint: "transactions/\(transaction.id)", method: .put, body: dto, context: context)
    }
    
    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        let id = transaction.id
        let title = transaction.title
        print("DEBUG: [TransactionService] deleteTransaction CALLED for: \(title) (ID: \(id))")
        
        // 1. Allocation Reversal: If this was an automated allocation, reset target wallet balance
        if title.hasPrefix("Alokasi ke ") {
            let targetName = String(title.dropFirst("Alokasi ke ".count))
            print("DEBUG: [TransactionService] Detected allocation removal for wallet: \(targetName)")
            
            // Note: Since predicates on relationship objects in SwiftData can be tricky, 
            // we fetch all and find by name for robustness in this simple schema.
            let walletFetch = FetchDescriptor<Wallet>()
            if let targetWallet = try? context.fetch(walletFetch).first(where: { $0.name == targetName }) {
                print("DEBUG: [TransactionService] Reverting initial balance of \(targetName) to 0.")
                targetWallet.initialBalance = 0
                targetWallet.syncStatus = "pending"
                
                // Sync the wallet update
                let walletDto = targetWallet.toDTO()
                syncManager.enqueue(endpoint: "wallets/\(targetWallet.id)", method: .put, body: walletDto, context: context)
            }
        }
        
        context.delete(transaction)
        try? context.save() // Critical: Persist deletion locally
        
        print("DEBUG: [TransactionService] deleteTransaction: Object removed from context locally.")
        
        syncManager.enqueue(endpoint: "transactions/\(id)", method: .delete, context: context)
    }
}
