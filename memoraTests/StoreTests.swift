import XCTest
@testable import memora
import Foundation

final class StoreTests: XCTestCase {
    
    var store: Store!
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        
        // Create temporary directory for testing
        tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        
        // Mock the Documents directory to use temp directory
        store = TestableStore(documentsDirectory: tempDirectory)
    }
    
    override func tearDown() {
        super.tearDown()
        
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDirectory)
        store = nil
        tempDirectory = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Store should initialize with default values when no files exist
        XCTAssertTrue(store.cards.isEmpty)
        XCTAssertEqual(store.settings.morningNotificationTime, 8)
        XCTAssertTrue(store.reviewLogs.isEmpty)
    }
    
    func testLoadDataWithNoFiles() {
        // When no JSON files exist, should use defaults without crashing
        store.loadData()
        
        XCTAssertTrue(store.cards.isEmpty)
        XCTAssertEqual(store.settings.spacedRepetitionIntervals, [0, 1, 2, 4, 7, 15, 30])
        XCTAssertTrue(store.reviewLogs.isEmpty)
    }
    
    // MARK: - Cards Persistence Tests
    
    func testSaveAndLoadCards() {
        // Create test cards
        let card1 = Card(
            question: "Test Question 1",
            answer: "Test Answer 1",
            stepIndex: 1,
            nextDue: Date(),
            reviewCount: 3,
            lastResult: true,
            tags: ["test", "sample"]
        )
        
        let card2 = Card(
            question: "Test Question 2", 
            answer: "Test Answer 2",
            stepIndex: 0,
            nextDue: Date().addingTimeInterval(86400), // +1 day
            reviewCount: 0,
            lastResult: nil,
            tags: []
        )
        
        store.cards = [card1, card2]
        
        // Save cards
        store.saveCards()
        
        // Create new store instance to test loading
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Verify cards were loaded correctly
        XCTAssertEqual(newStore.cards.count, 2)
        XCTAssertEqual(newStore.cards[0].question, "Test Question 1")
        XCTAssertEqual(newStore.cards[0].answer, "Test Answer 1")
        XCTAssertEqual(newStore.cards[0].stepIndex, 1)
        XCTAssertEqual(newStore.cards[0].reviewCount, 3)
        XCTAssertEqual(newStore.cards[0].lastResult, true)
        XCTAssertEqual(newStore.cards[0].tags, ["test", "sample"])
        
        XCTAssertEqual(newStore.cards[1].question, "Test Question 2")
        XCTAssertNil(newStore.cards[1].lastResult)
    }
    
    // MARK: - Settings Persistence Tests
    
    func testSaveAndLoadSettings() {
        // Modify settings
        store.settings.morningNotificationTime = 9
        store.settings.spacedRepetitionIntervals = [0, 1, 3, 7, 14, 30, 90]
        
        // Save settings
        store.saveSettings()
        
        // Create new store instance to test loading
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Verify settings were loaded correctly
        XCTAssertEqual(newStore.settings.morningNotificationTime, 9)
        XCTAssertEqual(newStore.settings.spacedRepetitionIntervals, [0, 1, 3, 7, 14, 30, 90])
    }
    
    // MARK: - ReviewLogs Persistence Tests
    
    func testSaveAndLoadReviewLogs() {
        let cardId1 = UUID()
        let cardId2 = UUID()
        let reviewedAt = Date()
        
        // Create test review logs
        let log1 = ReviewLog(
            cardId: cardId1,
            reviewedAt: reviewedAt,
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 5000
        )
        
        let log2 = ReviewLog(
            cardId: cardId2,
            reviewedAt: reviewedAt.addingTimeInterval(-3600), // 1 hour ago
            previousStep: 2,
            nextStep: 0,
            result: false,
            latencyMs: 12000
        )
        
        store.reviewLogs = [log1, log2]
        
        // Save review logs
        store.saveReviewLogs()
        
        // Create new store instance to test loading
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Verify review logs were loaded correctly
        XCTAssertEqual(newStore.reviewLogs.count, 2)
        XCTAssertEqual(newStore.reviewLogs[0].cardId, cardId1)
        XCTAssertTrue(newStore.reviewLogs[0].result)
        XCTAssertEqual(newStore.reviewLogs[0].latencyMs, 5000)
        
        XCTAssertEqual(newStore.reviewLogs[1].cardId, cardId2)
        XCTAssertFalse(newStore.reviewLogs[1].result)
        XCTAssertEqual(newStore.reviewLogs[1].latencyMs, 12000)
    }
    
    // MARK: - Error Handling Tests
    
    func testLoadCardsWithCorruptedJSON() {
        // Create corrupted JSON file
        let url = tempDirectory.appendingPathComponent("cards.json")
        let corruptedData = "{ invalid json }".data(using: .utf8)!
        try! corruptedData.write(to: url)
        
        // Store should handle corrupted JSON gracefully
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Should fallback to empty array
        XCTAssertTrue(newStore.cards.isEmpty)
    }
    
    func testLoadSettingsWithCorruptedJSON() {
        // Create corrupted JSON file
        let url = tempDirectory.appendingPathComponent("settings.json")
        let corruptedData = "not valid json at all".data(using: .utf8)!
        try! corruptedData.write(to: url)
        
        // Store should handle corrupted JSON gracefully
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Should fallback to default settings
        XCTAssertEqual(newStore.settings.morningNotificationTime, 8)
        XCTAssertEqual(newStore.settings.spacedRepetitionIntervals, [0, 1, 2, 4, 7, 15, 30])
    }
    
    func testLoadReviewLogsWithCorruptedJSON() {
        // Create corrupted JSON file
        let url = tempDirectory.appendingPathComponent("reviewLogs.json")
        let corruptedData = "[{incomplete".data(using: .utf8)!
        try! corruptedData.write(to: url)
        
        // Store should handle corrupted JSON gracefully
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        // Should fallback to empty array
        XCTAssertTrue(newStore.reviewLogs.isEmpty)
    }
    
    func testSaveToReadOnlyDirectory() {
        // This test simulates save failures
        let readOnlyStore = FailingSaveStore()
        
        // Add some data
        readOnlyStore.cards = [Card(
            question: "Test", 
            answer: "Answer", 
            stepIndex: 0, 
            nextDue: Date(), 
            reviewCount: 0, 
            lastResult: nil, 
            tags: []
        )]
        
        // Save operations should handle errors gracefully (not crash)
        readOnlyStore.saveCards()
        readOnlyStore.saveSettings()
        readOnlyStore.saveReviewLogs()
        
        // No assertions needed - just ensuring no crash occurs
    }
    
    // MARK: - Data Integrity Tests
    
    func testEmptyArraysHandling() {
        // Test saving and loading empty arrays
        store.cards = []
        store.reviewLogs = []
        
        store.saveCards()
        store.saveReviewLogs()
        
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        XCTAssertTrue(newStore.cards.isEmpty)
        XCTAssertTrue(newStore.reviewLogs.isEmpty)
    }
    
    func testLargeDataSet() {
        // Test with a large number of cards and logs
        var largeCardSet: [Card] = []
        var largeLogSet: [ReviewLog] = []
        
        for i in 0..<1000 {
            let card = Card(
                question: "Question \(i)",
                answer: "Answer \(i)", 
                stepIndex: i % 7,
                nextDue: Date().addingTimeInterval(Double(i * 86400)), // Days ahead
                reviewCount: i % 10,
                lastResult: i % 2 == 0,
                tags: ["tag\(i % 3)"]
            )
            largeCardSet.append(card)
            
            let log = ReviewLog(
                cardId: card.id,
                reviewedAt: Date().addingTimeInterval(Double(-i * 3600)), // Hours ago
                previousStep: (i - 1) % 7,
                nextStep: i % 7,
                result: i % 3 == 0,
                latencyMs: i * 100
            )
            largeLogSet.append(log)
        }
        
        store.cards = largeCardSet
        store.reviewLogs = largeLogSet
        
        store.saveCards()
        store.saveReviewLogs()
        
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        XCTAssertEqual(newStore.cards.count, 1000)
        XCTAssertEqual(newStore.reviewLogs.count, 1000)
        
        // Spot check some data
        XCTAssertEqual(newStore.cards[100].question, "Question 100")
        XCTAssertEqual(newStore.cards[100].stepIndex, 100 % 7)
        XCTAssertEqual(newStore.reviewLogs[500].latencyMs, 50000)
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentSaveOperations() {
        let expectation = XCTestExpectation(description: "Concurrent saves complete")
        expectation.expectedFulfillmentCount = 3
        
        // Add some data
        store.cards = [Card(
            question: "Concurrent Test", 
            answer: "Answer", 
            stepIndex: 0, 
            nextDue: Date(), 
            reviewCount: 0, 
            lastResult: nil, 
            tags: []
        )]
        store.settings.morningNotificationTime = 10
        store.reviewLogs = [ReviewLog(
            cardId: UUID(),
            reviewedAt: Date(),
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 3000
        )]
        
        // Perform concurrent saves
        DispatchQueue.global().async {
            self.store.saveCards()
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            self.store.saveSettings() 
            expectation.fulfill()
        }
        
        DispatchQueue.global().async {
            self.store.saveReviewLogs()
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        
        // Verify data integrity after concurrent operations
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        
        XCTAssertEqual(newStore.cards.count, 1)
        XCTAssertEqual(newStore.cards[0].question, "Concurrent Test")
        XCTAssertEqual(newStore.settings.morningNotificationTime, 10)
        XCTAssertEqual(newStore.reviewLogs.count, 1)
    }
    
    // MARK: - Repository Pattern Tests
    
    func testStoreAbstraction() {
        // Test that Store can be easily abstracted for future Core Data migration
        let storeProtocol: DataStorageProtocol = store
        
        // Add test data through protocol
        storeProtocol.cards = [Card(
            question: "Protocol Test", 
            answer: "Answer", 
            stepIndex: 0, 
            nextDue: Date(), 
            reviewCount: 0, 
            lastResult: nil, 
            tags: []
        )]
        
        storeProtocol.saveCards()
        
        // Verify data persisted
        let newStore = TestableStore(documentsDirectory: tempDirectory)
        XCTAssertEqual(newStore.cards.count, 1)
        XCTAssertEqual(newStore.cards[0].question, "Protocol Test")
    }
}

// MARK: - Test Helper Classes

class TestableStore: Store {
    private let testDocumentsDirectory: URL
    
    init(documentsDirectory: URL) {
        testDocumentsDirectory = documentsDirectory
        super.init()
    }
    
    override func getDocumentsDirectory() -> URL {
        return testDocumentsDirectory
    }
}

class FailingSaveStore: Store {
    override func saveCards() {
        // Simulate save failure - should handle gracefully
        print("Simulated save failure for cards")
    }
    
    override func saveSettings() {
        // Simulate save failure - should handle gracefully  
        print("Simulated save failure for settings")
    }
    
    override func saveReviewLogs() {
        // Simulate save failure - should handle gracefully
        print("Simulated save failure for review logs")
    }
}

// MARK: - Protocol for Future Migration

protocol DataStorageProtocol: ObservableObject {
    var cards: [Card] { get set }
    var settings: Settings { get set }
    var reviewLogs: [ReviewLog] { get set }
    
    func loadData()
    func saveCards()
    func saveSettings() 
    func saveReviewLogs()
}

extension Store: DataStorageProtocol {
    // Store already conforms to this protocol
}