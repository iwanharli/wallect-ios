import Foundation

// MARK: - Auth
struct AuthResponse: Codable {
    let token: String
    let user: UserDTO
}

struct UserDTO: Codable {
    let id: String
    let email: String
    let name: String?
}

// MARK: - Data Models
struct TransactionDTO: Codable {
    let id: String
    let title: String
    let amount: Double
    let category: String
    let date: Date
    let note: String?
    let isExpense: Bool
    let walletId: String?
}

struct WalletDTO: Codable {
    let id: String
    let name: String
    let type: String
    let icon: String
    let initialBalance: Double
}

struct CategoryDTO: Codable {
    let id: String
    let name: String
    let icon: String
    let isExpense: Bool
}

struct BudgetDTO: Codable {
    let id: String
    let category: String
    let limit: Double
}

// MARK: - Analytics
struct AnalyticsSummary: Codable {
    let totalIncome: Double
    let totalExpense: Double
    let balance: Double
    let categoryStats: [CategoryStatDTO]
}

struct CategoryStatDTO: Codable {
    let name: String
    let amount: Double
}
