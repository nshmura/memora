//
//  CardsViewModelTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
@testable import memora

@MainActor
final class CardsViewModelTests: XCTestCase {
    var viewModel: CardsViewModel!
    var mockStore: Store!
    
    override func setUpWithError() throws {
        mockStore = Store()
        mockStore.cards = []  // Start with empty cards
        viewModel = CardsViewModel(store: mockStore)
    }
    
    override func tearDownWithError() throws {
        viewModel = nil
        mockStore = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() throws {
        XCTAssertEqual(viewModel.cards.count, 0)
        XCTAssertEqual(viewModel.filteredCards.count, 0)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedTag, "全て")
        XCTAssertEqual(viewModel.availableTags, ["全て"])
        XCTAssertFalse(viewModel.isAddingCard)
        XCTAssertNil(viewModel.editingCard)
    }
    
    func testLoadCards() throws {
        // Add test data to store
        mockStore.cards = [
            Card(question: "Question 1", answer: "Answer 1", tags: ["tag1"]),
            Card(question: "Question 2", answer: "Answer 2", tags: ["tag2"])
        ]
        
        viewModel.loadCards()
        
        XCTAssertEqual(viewModel.cards.count, 2)
        XCTAssertEqual(viewModel.filteredCards.count, 2)
        XCTAssertEqual(Set(viewModel.availableTags), Set(["全て", "tag1", "tag2"]))
    }
    
    // MARK: - Card CRUD Tests
    
    func testAddCard() throws {
        let initialCount = mockStore.cards.count
        
        viewModel.addCard(question: "Test Question", answer: "Test Answer", tags: ["test"])
        
        XCTAssertEqual(mockStore.cards.count, initialCount + 1)
        
        let addedCard = mockStore.cards.last!
        XCTAssertEqual(addedCard.question, "Test Question")
        XCTAssertEqual(addedCard.answer, "Test Answer")
        XCTAssertEqual(addedCard.tags, ["test"])
        XCTAssertEqual(addedCard.stepIndex, 0)
        XCTAssertEqual(addedCard.reviewCount, 0)
        XCTAssertNil(addedCard.lastResult)
    }
    
    func testAddCardTrimsWhitespace() throws {
        viewModel.addCard(question: "  Question  ", answer: "  Answer  ", tags: ["  tag  "])
        
        let addedCard = mockStore.cards.last!
        XCTAssertEqual(addedCard.question, "Question")
        XCTAssertEqual(addedCard.answer, "Answer")
        XCTAssertEqual(addedCard.tags, ["tag"])
    }
    
    func testAddCardEmptyInput() throws {
        let initialCount = mockStore.cards.count
        
        // Empty question
        viewModel.addCard(question: "", answer: "Answer")
        XCTAssertEqual(mockStore.cards.count, initialCount)
        
        // Empty answer
        viewModel.addCard(question: "Question", answer: "")
        XCTAssertEqual(mockStore.cards.count, initialCount)
        
        // Whitespace only
        viewModel.addCard(question: "   ", answer: "   ")
        XCTAssertEqual(mockStore.cards.count, initialCount)
    }
    
    func testUpdateCard() throws {
        let card = Card(question: "Original", answer: "Original", tags: ["original"])
        mockStore.cards = [card]
        viewModel.loadCards()
        
        var updatedCard = card
        updatedCard.question = "Updated"
        updatedCard.answer = "Updated"
        updatedCard.tags = ["updated"]
        
        viewModel.updateCard(updatedCard)
        
        let storedCard = mockStore.cards.first!
        XCTAssertEqual(storedCard.question, "Updated")
        XCTAssertEqual(storedCard.answer, "Updated")
        XCTAssertEqual(storedCard.tags, ["updated"])
    }
    
    func testUpdateCardTrimsWhitespace() throws {
        let card = Card(question: "Original", answer: "Original")
        mockStore.cards = [card]
        viewModel.loadCards()
        
        var updatedCard = card
        updatedCard.question = "  Updated  "
        updatedCard.answer = "  Updated  "
        updatedCard.tags = ["  tag  ", ""]
        
        viewModel.updateCard(updatedCard)
        
        let storedCard = mockStore.cards.first!
        XCTAssertEqual(storedCard.question, "Updated")
        XCTAssertEqual(storedCard.answer, "Updated")
        XCTAssertEqual(storedCard.tags, ["tag"]) // Empty tags filtered out
    }
    
    func testDeleteCard() throws {
        let card1 = Card(question: "Q1", answer: "A1")
        let card2 = Card(question: "Q2", answer: "A2")
        mockStore.cards = [card1, card2]
        viewModel.loadCards()
        
        viewModel.deleteCard(card1)
        
        XCTAssertEqual(mockStore.cards.count, 1)
        XCTAssertEqual(mockStore.cards.first!.question, "Q2")
    }
    
    // MARK: - Search and Filter Tests
    
    func testSearchFilter() throws {
        mockStore.cards = [
            Card(question: "Apple", answer: "りんご", tags: ["fruit"]),
            Card(question: "Orange", answer: "オレンジ", tags: ["fruit"]),
            Card(question: "Car", answer: "車", tags: ["transport"])
        ]
        viewModel.loadCards()
        
        // Search by question
        viewModel.searchText = "Apple"
        XCTAssertEqual(viewModel.filteredCards.count, 1)
        XCTAssertEqual(viewModel.filteredCards.first!.question, "Apple")
        
        // Search by answer
        viewModel.searchText = "車"
        XCTAssertEqual(viewModel.filteredCards.count, 1)
        XCTAssertEqual(viewModel.filteredCards.first!.question, "Car")
        
        // Search by tag
        viewModel.searchText = "fruit"
        XCTAssertEqual(viewModel.filteredCards.count, 2)
        
        // Case insensitive search
        viewModel.searchText = "apple"
        XCTAssertEqual(viewModel.filteredCards.count, 1)
        
        // Clear search
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredCards.count, 3)
    }
    
    func testTagFilter() throws {
        mockStore.cards = [
            Card(question: "Q1", answer: "A1", tags: ["math"]),
            Card(question: "Q2", answer: "A2", tags: ["english"]),
            Card(question: "Q3", answer: "A3", tags: ["math", "hard"])
        ]
        viewModel.loadCards()
        
        // All cards
        viewModel.selectedTag = "全て"
        XCTAssertEqual(viewModel.filteredCards.count, 3)
        
        // Math tag
        viewModel.selectedTag = "math"
        XCTAssertEqual(viewModel.filteredCards.count, 2)
        
        // English tag
        viewModel.selectedTag = "english"
        XCTAssertEqual(viewModel.filteredCards.count, 1)
        
        // Non-existent tag
        viewModel.selectedTag = "science"
        XCTAssertEqual(viewModel.filteredCards.count, 0)
    }
    
    func testCombinedSearchAndTagFilter() throws {
        mockStore.cards = [
            Card(question: "Apple Math", answer: "A1", tags: ["math"]),
            Card(question: "Orange Math", answer: "A2", tags: ["math"]),
            Card(question: "Apple English", answer: "A3", tags: ["english"])
        ]
        viewModel.loadCards()
        
        viewModel.selectedTag = "math"
        viewModel.searchText = "Apple"
        
        XCTAssertEqual(viewModel.filteredCards.count, 1)
        XCTAssertEqual(viewModel.filteredCards.first!.question, "Apple Math")
    }
    
    func testAvailableTagsUpdate() throws {
        mockStore.cards = [
            Card(question: "Q1", answer: "A1", tags: ["math", "easy"]),
            Card(question: "Q2", answer: "A2", tags: ["english"]),
            Card(question: "Q3", answer: "A3", tags: ["math"])
        ]
        viewModel.loadCards()
        
        let expectedTags = Set(["全て", "easy", "english", "math"])
        XCTAssertEqual(Set(viewModel.availableTags), expectedTags)
    }
    
    // MARK: - Utility Function Tests
    
    func testGetCard() throws {
        let card = Card(question: "Test", answer: "Test")
        mockStore.cards = [card]
        viewModel.loadCards()
        
        let foundCard = viewModel.getCard(by: card.id)
        XCTAssertNotNil(foundCard)
        XCTAssertEqual(foundCard!.id, card.id)
        
        let notFoundCard = viewModel.getCard(by: UUID())
        XCTAssertNil(notFoundCard)
    }
    
    func testCardCounts() throws {
        let today = DateUtility.startOfDay(for: Date())
        let tomorrow = DateUtility.addDays(to: today, days: 1)
        
        var newCard = Card(question: "New", answer: "New")
        newCard.nextDue = today // Explicitly set new card due today
        
        var reviewedCard = Card(question: "Reviewed", answer: "Reviewed")
        reviewedCard.reviewCount = 5
        reviewedCard.nextDue = today // Due today
        
        var futureCard = Card(question: "Future", answer: "Future")
        futureCard.reviewCount = 2
        futureCard.nextDue = tomorrow // Due tomorrow
        
        mockStore.cards = [newCard, reviewedCard, futureCard]
        viewModel.loadCards()
        
        XCTAssertEqual(viewModel.cardCount(), 3)
        XCTAssertEqual(viewModel.getNewCardsCount(), 1) // newCard
        XCTAssertEqual(viewModel.getReviewedCardsCount(), 2) // reviewedCard, futureCard
        XCTAssertEqual(viewModel.getDueTodayCount(), 2) // newCard, reviewedCard
    }
    
    // MARK: - UI Helper Tests
    
    func testUIHelpers() throws {
        let card = Card(question: "Test", answer: "Test")
        
        // Test adding card state
        viewModel.startAddingCard()
        XCTAssertTrue(viewModel.isAddingCard)
        
        viewModel.stopAddingCard()
        XCTAssertFalse(viewModel.isAddingCard)
        
        // Test editing card state
        viewModel.startEditingCard(card)
        XCTAssertEqual(viewModel.editingCard?.id, card.id)
        
        viewModel.stopEditingCard()
        XCTAssertNil(viewModel.editingCard)
        
        // Test clear search
        viewModel.searchText = "test"
        viewModel.selectedTag = "math"
        viewModel.clearSearch()
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedTag, "全て")
    }
    
    // MARK: - Store Update Test
    
    func testUpdateStore() throws {
        let newStore = Store()
        newStore.cards = [Card(question: "New Store", answer: "New Store")]
        
        viewModel.updateStore(newStore)
        
        XCTAssertEqual(viewModel.cards.count, 1)
        XCTAssertEqual(viewModel.cards.first!.question, "New Store")
    }
}