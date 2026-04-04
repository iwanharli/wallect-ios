import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case unauthorized
    case serverError(Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL tidak valid."
        case .networkError(let error): return "Gagal terhubung ke server: \(error.localizedDescription)"
        case .unauthorized: return "Sesi telah berakhir atau tidak valid."
        case .serverError(let code): return "Kesalahan server dengan kode \(code)."
        case .decodingError(let error): return "Gagal membaca respons dari server: \(error.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    
    private let baseURL = URL(string: "http://192.168.0.21:3000")! // Update to actual server IP for real device
    private let session = URLSession.shared
    
    private var jwtToken: String? {
        // Secure token from Keychain (to be implemented in AuthManager)
        UserDefaults.standard.string(forKey: "auth_token")
    }
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    private let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: (any Codable)? = nil
    ) async throws -> T {
        let url = baseURL.appending(path: endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = jwtToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Body
        if let body = body {
            if let dataBody = body as? Data {
                request.httpBody = dataBody
            } else {
                request.httpBody = try jsonEncoder.encode(body)
            }
        }
        
        // Network Call
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "Invalid Response", code: 0))
        }
        
        // Check Status
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        // Decode
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
