import Foundation
import SwiftData

@MainActor
class DataController {
    static let shared = DataController()
    
    // Replace with your actual App Group ID from Apple Developer Portal
    static let appGroupIdentifier = "group.com.iwanharli.wallect"
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
            Transaction.self,
            Budget.self,
            Wallet.self,
            Category.self,
            SyncOperation.self,
            Debt.self
        ])
        
        let modelConfiguration: ModelConfiguration
        
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: DataController.appGroupIdentifier) {
            let sharedURL = groupURL.appendingPathComponent("Wallect.store")
            let fileManager = FileManager.default
            
            // FORCED MIGRATION: 
            let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let possibleOldNames = ["Wallect.store", "default.store", "wallect.store"]
            
            // Find the best candidate (the one with the largest file size)
            var bestCandidate: (url: URL, size: UInt64)?
            
            for name in possibleOldNames {
                let oldURL = appSupportURL.appendingPathComponent(name)
                if let attr = try? fileManager.attributesOfItem(atPath: oldURL.path),
                   let size = attr[.size] as? UInt64, size > 0 {
                    print("DEBUG: [DataController] Found candidate: \(name) (\(size) bytes)")
                    if size > (bestCandidate?.size ?? 0) {
                        bestCandidate = (oldURL, size)
                    }
                }
            }
            
            if let source = bestCandidate {
                print("DEBUG: [DataController] BEST candidate for migration: \(source.url.lastPathComponent) (\(source.size) bytes)")
                
                let storeExtensions = ["", "-shm", "-wal"]
                do {
                    // Always clear the existing shared store if we have a better local candidate
                    if fileManager.fileExists(atPath: sharedURL.path) {
                        print("DEBUG: [DataController] Clearing empty shared store for migration...")
                        for ext in storeExtensions {
                            let sharedFile = sharedURL.appendingPathExtension(ext)
                            if fileManager.fileExists(atPath: sharedFile.path) {
                                try fileManager.removeItem(at: sharedFile)
                            }
                        }
                    }
                    
                    for ext in storeExtensions {
                        let oldFile = source.url.appendingPathExtension(ext)
                        let newFile = sharedURL.appendingPathExtension(ext)
                        if fileManager.fileExists(atPath: oldFile.path) {
                            try fileManager.copyItem(at: oldFile, to: newFile)
                            print("DEBUG: [DataController] Copied \(source.url.lastPathComponent)\(ext)")
                        }
                    }
                    print("DEBUG: [DataController] FORCED Migration SUCCESS.")
                } catch {
                    print("DEBUG: [DataController] Migration ERROR: \(error)")
                }
            } else {
                print("DEBUG: [DataController] No valid local data found for migration.")
            }
            
            modelConfiguration = ModelConfiguration(schema: schema, url: sharedURL)
            print("DEBUG: [DataController] Using App Group URL: \(sharedURL.path)")
        } else {
            modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            print("DEBUG: [DataController] App Group NOT FOUND. Using local storage.")
        }
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("ERROR: [DataController] ModelContainer failed! \(error)")
            // Fallback for Widget stability
            let fallbackConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try! ModelContainer(for: schema, configurations: [fallbackConfig])
        }
    }
}
