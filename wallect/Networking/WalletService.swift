import Foundation
import SwiftData

@MainActor
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
        
        // If wallet is being archived, return balance to main
        if wallet.isGoal && wallet.isArchived {
            returnBalanceToMain(from: wallet, context: context)
        }
        
        let dto = wallet.toDTO()
        syncManager.enqueue(endpoint: "wallets/\(wallet.id)", method: .put, body: dto, context: context)
    }
    
    func deleteWallet(_ wallet: Wallet, currentBalance: Double, context: ModelContext) {
        let id = wallet.id
        
        // 1. Balance Reversal
        returnBalanceToMain(from: wallet, context: context)
        
        // 2. Perform Cascade Delete
        context.delete(wallet)
        try? context.save()
        
        // 3. Sync deletion to server
        syncManager.enqueue(endpoint: "wallets/\(id)", method: .delete, context: context)
    }
    
    func returnBalanceToMain(from wallet: Wallet, context: ModelContext) {
        let balance = wallet.currentBalance
        guard balance > 0 else { return }
        
        let mainWalletFetch = FetchDescriptor<Wallet>()
        let mainWallet = (try? context.fetch(mainWalletFetch))?.first(where: { 
            $0.name.localizedCaseInsensitiveCompare("Dompet Utama") == .orderedSame 
        })
        
        if let mainWallet = mainWallet {
            // Transaction in MAIN WALLET (Income)
            let reversalTx = Transaction(
                title: "Pengembalian dari \(wallet.name)",
                amount: balance,
                category: "Lainnya",
                date: .now,
                isExpense: false,
                wallet: mainWallet
            )
            context.insert(reversalTx)
            syncManager.enqueue(endpoint: "transactions", method: .post, body: reversalTx.toDTO(), context: context)
            
            // Transaction in GOAL WALLET (Expense) - to zero it out
            let withdrawalTx = Transaction(
                title: "Pengembalian ke Dompet Utama",
                amount: balance,
                category: "Lainnya",
                date: .now,
                isExpense: true,
                wallet: wallet
            )
            context.insert(withdrawalTx)
            syncManager.enqueue(endpoint: "transactions", method: .post, body: withdrawalTx.toDTO(), context: context)
            
            try? context.save()
        }
    }
    
    func processExpiredGoals(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Wallet>(
            predicate: #Predicate<Wallet> { wallet in
                wallet.isGoal && !wallet.isArchived
            }
        )
        
        guard let wallets = try? context.fetch(fetchDescriptor) else { return }
        
        let now = Date()
        var updatedCount = 0
        
        for wallet in wallets {
            if let endDate = wallet.endDate, endDate < now {
                // 1. Move money first
                returnBalanceToMain(from: wallet, context: context)
                
                // 2. Archive
                wallet.isArchived = true
                wallet.syncStatus = "pending"
                
                let dto = wallet.toDTO()
                syncManager.enqueue(endpoint: "wallets/\(wallet.id)", method: .put, body: dto, context: context)
                updatedCount += 1
            }
        }
        
        if updatedCount > 0 {
            try? context.save()
            print("Auto-archived and reversed \(updatedCount) expired goals")
        }
    }
}
