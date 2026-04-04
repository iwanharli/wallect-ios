import Foundation
import SwiftData

class SyncService {
    static let shared = SyncService()
    private let apiClient = APIClient.shared
    
    @MainActor
    func fetchAll(context: ModelContext) async {
        print("Starting full data hydration...")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchWallets(context: context) }
            group.addTask { await self.fetchCategories(context: context) }
            group.addTask { await self.fetchTransactions(context: context) }
            group.addTask { await self.fetchBudgets(context: context) }
        }
        
        print("Data hydration completed.")
    }
    
    @MainActor
    private func fetchWallets(context: ModelContext) async {
        do {
            let dtos: [WalletDTO] = try await apiClient.request(endpoint: "wallets")
            for dto in dtos {
                let fetchDescriptor = FetchDescriptor<Wallet>(predicate: #Predicate { $0.id == dto.id })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.name = dto.name
                    existing.type = dto.type
                    existing.icon = dto.icon
                    existing.initialBalance = dto.initialBalance
                    existing.syncStatus = "synced"
                } else {
                    let newWallet = Wallet(
                        id: dto.id,
                        name: dto.name,
                        type: WalletType(rawValue: dto.type) ?? .cash,
                        initialBalance: dto.initialBalance
                    )
                    newWallet.syncStatus = "synced"
                    context.insert(newWallet)
                }
            }
            try? context.save()
        } catch {
            print("Failed to fetch wallets: \(error)")
        }
    }
    
    @MainActor
    private func fetchCategories(context: ModelContext) async {
        do {
            let dtos: [CategoryDTO] = try await apiClient.request(endpoint: "categories")
            for dto in dtos {
                let fetchDescriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.id == dto.id })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.name = dto.name
                    existing.icon = dto.icon
                    existing.isExpense = dto.isExpense
                    existing.syncStatus = "synced"
                } else {
                    let newCat = Category(
                        id: dto.id,
                        name: dto.name,
                        icon: dto.icon,
                        isExpense: dto.isExpense
                    )
                    newCat.syncStatus = "synced"
                    context.insert(newCat)
                }
            }
            try? context.save()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    @MainActor
    private func fetchTransactions(context: ModelContext) async {
        do {
            let dtos: [TransactionDTO] = try await apiClient.request(endpoint: "transactions")
            for dto in dtos {
                let fetchDescriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.id == dto.id })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.title = dto.title
                    existing.amount = dto.amount
                    existing.category = dto.category
                    existing.date = dto.date
                    existing.note = dto.note ?? ""
                    existing.isExpense = dto.isExpense
                    existing.syncStatus = "synced"
                } else {
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
                    context.insert(newTx)
                }
            }
            try? context.save()
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }
    
    @MainActor
    private func fetchBudgets(context: ModelContext) async {
        do {
            let dtos: [BudgetDTO] = try await apiClient.request(endpoint: "budgets")
            for dto in dtos {
                let fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate { $0.id == dto.id })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.category = dto.category
                    existing.limit = dto.limit
                    existing.syncStatus = "synced"
                } else {
                    let newBudget = Budget(
                        id: dto.id,
                        category: dto.category,
                        limit: dto.limit
                    )
                    newBudget.syncStatus = "synced"
                    context.insert(newBudget)
                }
            }
            try? context.save()
        } catch {
            print("Failed to fetch budgets: \(error)")
        }
    }
}
