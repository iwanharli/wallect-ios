import Foundation
import SwiftData

class TransactionService {
    static let shared = TransactionService()
    
    private let apiClient = APIClient.shared
    private let syncManager = SyncManager.shared
    
    func fetchTransactions(context: ModelContext) async {
        do {
            let dtos: [TransactionDTO] = try await apiClient.request(endpoint: "transactions")
            
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
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }
    
    func createTransaction(_ transaction: Transaction, context: ModelContext) {
        context.insert(transaction)
        transaction.syncStatus = "pending"
        
        let dto = transaction.toDTO()
        syncManager.enqueue(endpoint: "transactions", method: .post, body: dto, context: context)
    }

    func updateTransaction(_ transaction: Transaction, context: ModelContext) {
        transaction.syncStatus = "pending"
        
        let dto = transaction.toDTO()
        syncManager.enqueue(endpoint: "transactions/\(transaction.id)", method: .put, body: dto, context: context)
    }
    
    func deleteTransaction(_ transaction: Transaction, context: ModelContext) {
        let id = transaction.id
        context.delete(transaction)
        
        syncManager.enqueue(endpoint: "transactions/\(id)", method: .delete, context: context)
    }
}
