import Foundation
import SwiftData
import SwiftUI
import Combine

@Model
final class SyncOperation {
    var id: UUID
    var endpoint: String
    var method: String
    var body: Data?
    var createdAt: Date
    
    init(endpoint: String, method: String, body: Data? = nil) {
        self.id = UUID()
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.createdAt = Date()
    }
}

class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    private let apiClient = APIClient.shared
    
    @MainActor
    func enqueue(endpoint: String, method: HTTPMethod, body: (any Codable)? = nil, context: ModelContext) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let bodyData = try? body.flatMap { try encoder.encode($0) }
        
        let operation = SyncOperation(endpoint: endpoint, method: method.rawValue, body: bodyData)
        context.insert(operation)
        
        // Process queue immediately on the MainActor
        Task { @MainActor in
            await processQueue(context: context)
        }
    }
    
    @MainActor
    func processQueue(context: ModelContext) async {
        let fetchDescriptor = FetchDescriptor<SyncOperation>(sortBy: [SortDescriptor(\.createdAt)])
        
        guard let operations = try? context.fetch(fetchDescriptor) else { return }
        
        for operation in operations {
            do {
                // Try executing the network call
                let _: APIResponse = try await apiClient.request(
                    endpoint: operation.endpoint,
                    method: HTTPMethod(rawValue: operation.method) ?? .post,
                    body: operation.body
                )
                
                // Success - remove from queue
                context.delete(operation)
            } catch {
                // Failure - report to server so we can see the exact cause
                let errStr = String(describing: error).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "unknown_error"
                print("Sync failed: \(error)")
                break // Stop processing for now to avoid order issues
            }
        }
    }
}

struct APIResponse: Codable {
    var success: Bool?
    var message: String?
}
