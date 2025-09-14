//
//  Store.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

class Store: ObservableObject {
    @Published var cards: [Card] = []
    @Published var settings: Settings = Settings()
    @Published var reviewLogs: [ReviewLog] = []
    
    init() {
        loadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        
        // Use Documents directory which is accessible from Files app
        // This is available without any special capabilities
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataDirectory = documentsDirectory.appendingPathComponent("data")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: dataDirectory.path) {
            do {
                try fileManager.createDirectory(at: dataDirectory, withIntermediateDirectories: true)
                print("Created documents directory: \(dataDirectory.path)")
                
                // Try to migrate data from old locations
                migrateFromOldLocations()
                
            } catch {
                print("Failed to create directory: \(error)")
                // Fallback to root documents directory
                return documentsDirectory
            }
        }
        
        print("Using Documents directory: \(dataDirectory.path)")
        return dataDirectory
    }
    
    func loadData() {
        loadCards()
        loadSettings()
        loadReviewLogs()
    }
    
    private func loadCards() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("cards.json")
            let data = try Data(contentsOf: url)
            cards = try JSONDecoder().decode([Card].self, from: data)
        } catch {
            print("Failed to load cards: \(error)")
            // Use empty array as default
            cards = []
        }
    }
    
    private func loadSettings() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("settings.json")
            let data = try Data(contentsOf: url)
            settings = try JSONDecoder().decode(Settings.self, from: data)
        } catch {
            print("Failed to load settings: \(error)")
            // Use default settings
            settings = Settings()
        }
    }
    
    private func loadReviewLogs() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("reviewLogs.json")
            let data = try Data(contentsOf: url)
            reviewLogs = try JSONDecoder().decode([ReviewLog].self, from: data)
        } catch {
            print("Failed to load review logs: \(error)")
            // Use empty array as default
            reviewLogs = []
        }
    }
    
    func saveCards() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("cards.json")
            let data = try JSONEncoder().encode(cards)
            try data.write(to: url)
        } catch {
            print("Failed to save cards: \(error)")
        }
    }
    
    func saveSettings() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("settings.json")
            let data = try JSONEncoder().encode(settings)
            try data.write(to: url)
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func saveReviewLogs() {
        do {
            let url = getDocumentsDirectory().appendingPathComponent("reviewLogs.json")
            let data = try JSONEncoder().encode(reviewLogs)
            try data.write(to: url)
        } catch {
            print("Failed to save review logs: \(error)")
        }
    }
    
    // MARK: - Data Migration
    
    private func migrateFromOldLocations() {
        let fileManager = FileManager.default
        let newDataDirectory = getDocumentsDirectory()
        let filesToMigrate = ["cards.json", "settings.json", "reviewLogs.json"]
        
        // Migration locations to check (in order of preference)
        let migrationSources: [(path: URL, description: String)] = [
            // 1. Documents/memora/data/ (previous location)
            (fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("memora").appendingPathComponent("data"), "Documents/memora/data"),
            // 2. Documents/Memora/ (earlier location)
            (fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Memora"), "Documents/Memora"),
            // 3. Application Support/Memora/ (original location)
            (fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("Memora"), "Application Support/Memora")
        ]
        
        var migratedFrom: String?
        
        for (sourcePath, description) in migrationSources {
            // Check if source directory exists
            guard fileManager.fileExists(atPath: sourcePath.path) else {
                continue
            }
            
            print("Checking for data to migrate from: \(description)")
            
            var hasDataToMigrate = false
            for filename in filesToMigrate {
                let oldFileURL = sourcePath.appendingPathComponent(filename)
                let newFileURL = newDataDirectory.appendingPathComponent(filename)
                
                // Skip if old file doesn't exist
                guard fileManager.fileExists(atPath: oldFileURL.path) else {
                    continue
                }
                
                // Skip if new file already exists (don't overwrite)
                guard !fileManager.fileExists(atPath: newFileURL.path) else {
                    print("Skipping \(filename) - already exists in new location")
                    continue
                }
                
                do {
                    try fileManager.copyItem(at: oldFileURL, to: newFileURL)
                    print("Migrated \(filename) from \(description)")
                    hasDataToMigrate = true
                } catch {
                    print("Failed to migrate \(filename) from \(description): \(error)")
                }
            }
            
            if hasDataToMigrate {
                migratedFrom = description
                break // Stop after first successful migration
            }
        }
        
        if let source = migratedFrom {
            print("Migration completed from: \(source). Old data preserved for safety.")
        } else {
            print("No old data to migrate")
        }
    }

    // MARK: - Update Methods
    
    func updateSettings(_ newSettings: Settings) {
        settings = newSettings
        saveSettings()
    }
    
    // MARK: - Test Methods
    
    func createTestData() {
        // Create test card data to initialize directory
        if cards.isEmpty {
            let testCard = Card(
                question: "テスト問題",
                answer: "テスト回答"
            )
            cards.append(testCard)
            saveCards()
            print("Test data created and saved to: \(getDocumentsDirectory().path)")
        }
    }
}
