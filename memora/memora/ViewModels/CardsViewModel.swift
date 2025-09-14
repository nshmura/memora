//
//  CardsViewModel.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var filteredCards: [Card] = []
    @Published var searchText: String = "" {
        didSet {
            applyFilters()
        }
    }
    @Published var selectedTag: String = "全て" {
        didSet {
            applyFilters()
        }
    }
    @Published var availableTags: [String] = ["全て"]
    @Published var isAddingCard: Bool = false
    @Published var editingCard: Card?
    
    private var store: Store
    
    init(store: Store = Store()) {
        self.store = store
        loadCards()
    }
    
    func updateStore(_ store: Store) {
        self.store = store
        loadCards()
    }
    
    // MARK: - Card Loading
    
    func loadCards() {
        cards = store.cards
        updateAvailableTags()
        applyFilters()
    }
    
    private func updateAvailableTags() {
        var tagSet = Set<String>()
        for card in cards {
            for tag in card.tags {
                tagSet.insert(tag)
            }
        }
        availableTags = ["全て"] + Array(tagSet).sorted()
    }
    
    // MARK: - Search and Filter
    
    private func applyFilters() {
        var result = cards
        
        // Apply tag filter
        if selectedTag != "全て" {
            result = result.filter { card in
                card.tags.contains(selectedTag)
            }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { card in
                card.question.localizedCaseInsensitiveContains(searchText) ||
                card.answer.localizedCaseInsensitiveContains(searchText) ||
                card.tags.contains { tag in
                    tag.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        filteredCards = result
    }
    
    // MARK: - Card CRUD Operations
    
    func addCard(question: String, answer: String, tags: [String] = []) {
        guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let newCard = Card(
            question: question.trimmingCharacters(in: .whitespacesAndNewlines),
            answer: answer.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        )
        
        store.cards.append(newCard)
        store.saveCards()
        loadCards()
    }
    
    func updateCard(_ card: Card) {
        guard !card.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !card.answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        if let index = store.cards.firstIndex(where: { $0.id == card.id }) {
            var updatedCard = card
            updatedCard.question = card.question.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedCard.answer = card.answer.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedCard.tags = card.tags.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            
            store.cards[index] = updatedCard
            store.saveCards()
            loadCards()
        }
    }
    
    func deleteCard(_ card: Card) {
        store.cards.removeAll { $0.id == card.id }
        store.saveCards()
        loadCards()
    }
    
    func deleteCards(at offsets: IndexSet) {
        let cardsToDelete = offsets.map { filteredCards[$0] }
        for card in cardsToDelete {
            store.cards.removeAll { $0.id == card.id }
        }
        store.saveCards()
        loadCards()
    }
    
    // MARK: - Card Management Utilities
    
    func getCard(by id: UUID) -> Card? {
        return cards.first { $0.id == id }
    }
    
    func cardCount() -> Int {
        return cards.count
    }
    
    func filteredCardCount() -> Int {
        return filteredCards.count
    }
    
    func getDueTodayCount() -> Int {
        let today = DateUtility.startOfDay(for: Date())
        return cards.filter { card in
            card.nextDue <= today
        }.count
    }
    
    func getReviewedCardsCount() -> Int {
        return cards.filter { card in
            card.reviewCount > 0
        }.count
    }
    
    func getNewCardsCount() -> Int {
        return cards.filter { card in
            card.reviewCount == 0
        }.count
    }
    
    // MARK: - UI Helpers
    
    func startAddingCard() {
        isAddingCard = true
    }
    
    func stopAddingCard() {
        isAddingCard = false
    }
    
    func startEditingCard(_ card: Card) {
        editingCard = card
    }
    
    func stopEditingCard() {
        editingCard = nil
    }
    
    func clearSearch() {
        searchText = ""
        selectedTag = "全て"
    }
}