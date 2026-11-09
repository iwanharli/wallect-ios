import Foundation
import SwiftData

@MainActor
class SyncService {
    static let shared = SyncService()
    private let apiClient = APIClient.shared
    
    // Concurrency Guard: Ensure only one hydration runs at a time
    private var isFetching = false
    
    @MainActor
    func fetchAll(context: ModelContext) async {
        guard !isFetching else {
            print("DEBUG: [SyncService] fetchAll already in progress. Skipping redundant call.")
            return
        }
        
        isFetching = true
        defer { isFetching = false }
        
        print("Starting full data hydration...")
        
        // reconcile existing local data before fetching from cloud
        await self.reconcileLocalDebts(context: context)
        
        if Task.isCancelled { return }
        await self.fetchWallets(context: context)
        
        if Task.isCancelled { return }
        await self.fetchCategories(context: context)
        
        if Task.isCancelled { return }
        await self.fetchTransactions(context: context)
        
        if Task.isCancelled { return }
        await self.fetchBudgets(context: context)
        
        if Task.isCancelled { return }
        await self.fetchDebts(context: context)
        
        if Task.isCancelled { return }
        // Ensure defaults only if sync resulted in empty data
        self.ensureDefaults(context: context)
        
        print("Data hydration completed.")
    }
    
    @MainActor
    private func fetchWallets(context: ModelContext) async {
        do {
            let dtos: [WalletDTO] = try await apiClient.request(endpoint: "wallets")
            for dto in dtos {
                let walletId = dto.id
                let fetchDescriptor = FetchDescriptor<Wallet>(predicate: #Predicate { $0.id == walletId })
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
                await Task.yield()
            }
            try? context.save()
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch wallets: \(error)")
            }
        }
    }
    
    @MainActor
    private func fetchCategories(context: ModelContext) async {
        do {
            let dtos: [CategoryDTO] = try await apiClient.request(endpoint: "categories")
            for dto in dtos {
                guard let catId = dto.id else { continue }
                let fetchDescriptor = FetchDescriptor<Category>(predicate: #Predicate { $0.id == catId })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.name = dto.name
                    existing.icon = dto.icon
                    existing.hexColor = dto.hexColor
                    existing.isExpense = dto.isExpense
                    existing.syncStatus = "synced"
                } else {
                    let newCat = Category(
                        id: dto.id ?? UUID().uuidString,
                        name: dto.name,
                        icon: dto.icon,
                        hexColor: dto.hexColor,
                        isExpense: dto.isExpense
                    )
                    newCat.syncStatus = "synced"
                    context.insert(newCat)
                }
                await Task.yield()
            }
            try? context.save()
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch categories: \(error)")
            }
        }
    }
    
    @MainActor
    private func fetchTransactions(context: ModelContext) async {
        do {
            let dtos: [TransactionDTO] = try await apiClient.request(endpoint: "transactions")
            for dto in dtos {
                let txId = dto.id
                let fetchDescriptor = FetchDescriptor<Transaction>(predicate: #Predicate { $0.id == txId })
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
                await Task.yield()
            }
            try? context.save()
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch transactions: \(error)")
            }
        }
    }
    
    @MainActor
    private func fetchBudgets(context: ModelContext) async {
        print("DEBUG: [SyncService] fetchBudgets starting...")
        do {
            let dtos: [BudgetDTO] = try await apiClient.request(endpoint: "budgets")
            print("DEBUG: [SyncService] fetchBudgets: Received \(dtos.count) budget(s) from server.")
            
            // Get all local budgets before update
            let localFetch = FetchDescriptor<Budget>()
            let localBudgets = (try? context.fetch(localFetch)) ?? []
            
            // If server returns empty, we should ONLY clear local IF we are sure they are not pending
            // For now, let's just log and see. 
            // In a real app, we might compare IDs.
            
            if dtos.isEmpty && !localBudgets.isEmpty {
                print("DEBUG: [SyncService] fetchBudgets: Server is empty, but local has \(localBudgets.count). Investigating...")
            }
            
            // Map of server budgets for easy lookup
            let serverIds = Set(dtos.map { $0.id })
            
            // 1. Delete local budgets that are NOT on the server AND are NOT pending sync
            for local in localBudgets {
                if !serverIds.contains(local.id) && local.syncStatus == "synced" {
                    print("DEBUG: [SyncService] Removing local budget not on server: \(local.category)")
                    context.delete(local)
                }
            }
            // 2. Update or Insert budgets from server
            for dto in dtos {
                let budgetId = dto.id
                let startDate = dto.startDate ?? Date.now
                let endDate = dto.endDate
                
                let fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate { $0.id == budgetId })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    print("DEBUG: [SyncService] fetchBudgets: Updating existing budget: \(dto.category) (ID: \(budgetId))")
                    existing.category = dto.category
                    existing.limit = dto.limit
                    existing.isRecurring = dto.isRecurring
                    existing.startDate = startDate
                    existing.endDate = endDate
                    existing.syncStatus = "synced"
                } else {
                    print("DEBUG: [SyncService] fetchBudgets: Inserting NEW budget: \(dto.category) (ID: \(budgetId))")
                    let newBudget = Budget(
                        id: budgetId,
                        category: dto.category,
                        limit: dto.limit,
                        isRecurring: dto.isRecurring,
                        startDate: startDate,
                        endDate: endDate
                    )
                    newBudget.syncStatus = "synced"
                    context.insert(newBudget)
                }
                
                await Task.yield()
            }
            
            try? context.save()
            print("DEBUG: [SyncService] fetchBudgets completed and saved context.")
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("DEBUG: [SyncService] fetchBudgets FAILED with error: \(error)")
            }
        }
    }
    
    @MainActor
    private func fetchDebts(context: ModelContext) async {
        do {
            let dtos: [DebtDTO] = try await apiClient.request(endpoint: "debts")
            for dto in dtos {
                let debtId = dto.id
                let fetchDescriptor = FetchDescriptor<Debt>(predicate: #Predicate { $0.id == debtId })
                if let existing = try? context.fetch(fetchDescriptor).first {
                    existing.title = dto.title
                    existing.amount = dto.amount
                    existing.personName = dto.personName
                    existing.isDebt = dto.isDebt
                    existing.dueDate = dto.dueDate
                    existing.isPaid = dto.isPaid
                    existing.note = dto.note ?? ""
                    existing.syncStatus = "synced"
                } else {
                    let newDebt = Debt(
                        id: dto.id,
                        title: dto.title,
                        amount: dto.amount,
                        personName: dto.personName,
                        isDebt: dto.isDebt,
                        dueDate: dto.dueDate,
                        isPaid: dto.isPaid,
                        note: dto.note ?? "",
                        syncStatus: "synced"
                    )
                    context.insert(newDebt)
                }
                await Task.yield()
            }
            try? context.save()
        } catch {
            if (error as? URLError)?.code != .cancelled {
                print("Failed to fetch debts: \(error)")
            }
        }
    }
    
    @MainActor
    private func reconcileLocalDebts(context: ModelContext) async {
        print("DEBUG: [SyncService] Force-reconciling all local debts to ensure cloud parity...")
        let fetchDescriptor = FetchDescriptor<Debt>()
        if let allDebts = try? context.fetch(fetchDescriptor) {
            print("DEBUG: [SyncService] Processing \(allDebts.count) total local debt(s) for cloud sync...")
            for debt in allDebts {
                // Enqueue to sync queue
                SyncManager.shared.enqueue(endpoint: "debts", method: .post, body: debt.toDTO(), context: context)
                // Mark locally as synced
                debt.syncStatus = "synced"
            }
            try? context.save()
            print("DEBUG: [SyncService] Reconciliation batch enqueued.")
        }
    }
    
    @MainActor
    private func ensureDefaults(context: ModelContext) {
        // Check Wallets
        let walletFetch = FetchDescriptor<Wallet>()
        if let wallets = try? context.fetch(walletFetch), wallets.isEmpty {
            let defaultWallet = Wallet(name: "Dompet Utama", type: .cash, initialBalance: 0)
            context.insert(defaultWallet)
            SyncManager.shared.enqueue(endpoint: "wallets", method: .post, body: defaultWallet.toDTO(), context: context)
        }
        
        // Check Categories
        let catFetch = FetchDescriptor<Category>()
        if let categories = try? context.fetch(catFetch), categories.isEmpty {
            let defaults = [
                Category(name: "Makanan", icon: "cart.fill", hexColor: "FF9F1C", isExpense: true),
                Category(name: "Belanja", icon: "bag.fill", hexColor: "FF006E", isExpense: true),
                Category(name: "Transport", icon: "car.fill", hexColor: "3A86FF", isExpense: true),
                Category(name: "Kerja", icon: "briefcase.fill", hexColor: "8338EC", isExpense: false),
                Category(name: "Hadiah", icon: "gift.fill", hexColor: "FB5607", isExpense: false),
                Category(name: "Lainnya", icon: "dollarsign.circle", hexColor: "00B4D8", isExpense: true)
            ]
            for cat in defaults {
                context.insert(cat)
                SyncManager.shared.enqueue(endpoint: "categories", method: .post, body: cat.toDTO(), context: context)
            }
        }
        
        try? context.save()
    }
    
    @MainActor
    func resetAllData(context: ModelContext) async throws {
        print("DEBUG: [SyncService] Starting total data reset...")
        
        // 1. Reset Cloud Data
        let _: [String: String] = try await apiClient.request(endpoint: "auth/reset", method: .delete)
        
        // 2. Clear Local Data
        if let transactions = try? context.fetch(FetchDescriptor<Transaction>()) {
            for tx in transactions { context.delete(tx) }
        }
        if let budgets = try? context.fetch(FetchDescriptor<Budget>()) {
            for b in budgets { context.delete(b) }
        }
        if let cats = try? context.fetch(FetchDescriptor<Category>()) {
            for c in cats { context.delete(c) }
        }
        if let wallets = try? context.fetch(FetchDescriptor<Wallet>()) {
            for w in wallets { context.delete(w) }
        }
        if let debts = try? context.fetch(FetchDescriptor<Debt>()) {
            for d in debts { context.delete(d) }
        }
        
        try context.save()
        print("DEBUG: [SyncService] Local data purge completed.")
        
        // 3. Re-ensure defaults
        self.ensureDefaults(context: context)
    }
}

