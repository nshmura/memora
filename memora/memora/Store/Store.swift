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
        let memoraDirectory = documentsDirectory.appendingPathComponent("Memora")
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: memoraDirectory.path) {
            do {
                try fileManager.createDirectory(at: memoraDirectory, withIntermediateDirectories: true)
                print("Created documents directory: \(memoraDirectory.path)")
                
                // Try to migrate data from old Application Support location
                migrateFromApplicationSupport()
                
            } catch {
                print("Failed to create directory: \(error)")
                // Fallback to root documents directory
                return documentsDirectory
            }
        }
        
        print("Using Documents directory: \(memoraDirectory.path)")
        return memoraDirectory
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
    
    private func migrateFromApplicationSupport() {
        let fileManager = FileManager.default
        
        // Get old Application Support directory
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        let oldMemoraDirectory = appSupportURL.appendingPathComponent("Memora")
        
        // Check if old directory exists
        guard fileManager.fileExists(atPath: oldMemoraDirectory.path) else {
            print("No old data to migrate")
            return
        }
        
        let newMemoraDirectory = getDocumentsDirectory()
        let filesToMigrate = ["cards.json", "settings.json", "reviewLogs.json"]
        
        print("Starting data migration from Application Support to Documents...")
        
        for filename in filesToMigrate {
            let oldFileURL = oldMemoraDirectory.appendingPathComponent(filename)
            let newFileURL = newMemoraDirectory.appendingPathComponent(filename)
            
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
                print("Migrated \(filename) to Documents directory")
            } catch {
                print("Failed to migrate \(filename): \(error)")
            }
        }
        
        // Optionally remove old directory after successful migration
        // We'll keep it for safety - users can manually delete it later
        print("Migration completed. Old data preserved in Application Support for safety.")
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
