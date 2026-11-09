import Foundation
import SwiftData

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
