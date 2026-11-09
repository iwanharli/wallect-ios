import Foundation
import CryptoKit

extension String {
    /// Returns the MD5 hash of the string, formatted for services like Gravatar
    var md5: String {
        let data = Data(self.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).utf8)
        let hash = Insecure.MD5.hash(data: data)
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Returns a Gravatar URL for the current string (assumed to be an email)
    var gravatarURL: URL? {
        let size = 200
        let hash = self.md5
        return URL(string: "https://www.gravatar.com/avatar/\(hash)?s=\(size)&d=mp")
    }
}
