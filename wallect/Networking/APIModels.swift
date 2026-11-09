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
    let isGoal: Bool?
    let targetAmount: Double?
    let startDate: Date?
    let endDate: Date?
    let isArchived: Bool?
}

struct CategoryDTO: Codable {
    let id: String?
    let name: String
    let icon: String
    let hexColor: String
    let isExpense: Bool
}

struct BudgetDTO: Codable {
    let id: String
    let category: String
    let limit: Double
    let isRecurring: Bool
    let startDate: Date?
    let endDate: Date
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

struct DebtDTO: Codable {
    let id: String
    let title: String
    let amount: Double
    let personName: String
    let isDebt: Bool
    let dueDate: Date?
    let isPaid: Bool
    let note: String?
}

// MARK: - QR Auth
struct QRAuthorizeRequest: Codable {
    let qrId: String
}

struct GenericResponse: Codable {
    let success: Bool
}

