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
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
}
