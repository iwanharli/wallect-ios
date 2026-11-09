import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    private let apiClient = APIClient.shared
    @Published var isSyncing = false
    @Published var lastError: String?
    
    private init() {}
    
    @MainActor
    func enqueue(endpoint: String, method: HTTPMethod, body: (any Codable)? = nil, context: ModelContext) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try? body.flatMap { try encoder.encode($0) }
        
        let operation = SyncOperation(endpoint: endpoint, method: method.rawValue, body: bodyData)
        context.insert(operation)
        try? context.save()
        
        Task { await processQueue(context: context) }
    }
    
    @MainActor
    func processQueue(context: ModelContext) async {
        // Prevent concurrent syncs
        guard !isSyncing else { return }
        
        let fetchDescriptor = FetchDescriptor<SyncOperation>(sortBy: [SortDescriptor(\.createdAt)])
        guard let operations = try? context.fetch(fetchDescriptor), !operations.isEmpty else { 
            return 
        }
        
        isSyncing = true
        defer { isSyncing = false }
        
        print("DEBUG: [SyncManager] Starting sync for \(operations.count) items...")
        
        for operation in operations {
            let method = HTTPMethod(rawValue: operation.method) ?? .post
            
            do {
                let _: BlankResponse = try await apiClient.request(
                    endpoint: operation.endpoint,
                    method: method,
                    body: operation.body
                )
                
                self.lastError = nil
                context.delete(operation)
                try? context.save()
                print("DEBUG: [SyncManager] Sync SUCCESS: \(operation.endpoint)")
            } catch let error as APIError {
                if case .unauthorized = error {
                    self.lastError = "Sesi berakhir. Silakan login kembali."
                    break
                }
                
                if case .serverError(let code, _) = error, code == 400 {
                    print("DEBUG: [SyncManager] PERMANENT ERROR (400) for \(operation.endpoint). Removing from queue.")
                    context.delete(operation)
                    try? context.save()
                    continue // Don't block subsequent items
                }
                
                // Stop queue on other network/server errors to maintain order
                print("DEBUG: [SyncManager] Sync PAUSED (Network/Server \(error.localizedDescription)): \(error.localizedDescription)")
                self.lastError = "Kesalahan jaringan: \(error.localizedDescription)"
                break 
            } catch {
                print("DEBUG: [SyncManager] Unknown error: \(error)")
                break
            }
        }
        
        print("DEBUG: [SyncManager] Sync cycle finished.")
    }
}

struct BlankResponse: Codable {}
