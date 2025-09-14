import XCTest
@testable import memora

final class ReviewLogTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testInitializationWithAllParameters() {
        let cardId = UUID()
        let beforeCreation = Date()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            previousStep: 2,
            nextStep: 3,
            result: true,
            latencyMs: 5000
        )
        
        let afterCreation = Date()
        
        XCTAssertNotNil(reviewLog.id)
        XCTAssertEqual(reviewLog.cardId, cardId)
        XCTAssertGreaterThanOrEqual(reviewLog.reviewedAt, beforeCreation)
        XCTAssertLessThanOrEqual(reviewLog.reviewedAt, afterCreation)
        XCTAssertEqual(reviewLog.previousStep, 2)
        XCTAssertEqual(reviewLog.nextStep, 3)
        XCTAssertEqual(reviewLog.result, true)
        XCTAssertEqual(reviewLog.latencyMs, 5000)
    }
    
    func testUniqueIdGeneration() {
        let cardId = UUID()
        
        let reviewLog1 = ReviewLog(
            cardId: cardId,
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 3000
        )
        
        let reviewLog2 = ReviewLog(
            cardId: cardId,
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 3000
        )
        
        XCTAssertNotEqual(reviewLog1.id, reviewLog2.id)
    }
    
    // MARK: - Step Transition Tests
    
    func testCorrectAnswerStepProgression() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 2,
            nextStep: 3,
            result: true,
            latencyMs: 4500
        )
        
        XCTAssertEqual(reviewLog.previousStep, 2)
        XCTAssertEqual(reviewLog.nextStep, 3)
        XCTAssertTrue(reviewLog.result)
    }
    
    func testIncorrectAnswerStepReset() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 4,
            nextStep: 0,
            result: false,
            latencyMs: 12000
        )
        
        XCTAssertEqual(reviewLog.previousStep, 4)
        XCTAssertEqual(reviewLog.nextStep, 0)
        XCTAssertFalse(reviewLog.result)
    }
    
    func testFirstReviewStartingStep() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 8000
        )
        
        XCTAssertEqual(reviewLog.previousStep, 0)
        XCTAssertEqual(reviewLog.nextStep, 1)
    }
    
    // MARK: - Date Handling Tests
    
    func testReviewedAtDatePersistence() {
        let cardId = UUID()
        let specificDate = Calendar.current.date(from: DateComponents(
            timeZone: TimeZone(identifier: "Asia/Tokyo"),
            year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 45
        ))!
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 1,
            nextStep: 2,
            result: true,
            latencyMs: 6000
        )
        
        XCTAssertEqual(reviewLog.reviewedAt, specificDate)
    }
    
    func testCurrentDateReview() {
        let cardId = UUID()
        let beforeDate = Date()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 3,
            nextStep: 4,
            result: true,
            latencyMs: 2500
        )
        
        let afterDate = Date()
        
        XCTAssertGreaterThanOrEqual(reviewLog.reviewedAt, beforeDate)
        XCTAssertLessThanOrEqual(reviewLog.reviewedAt, afterDate)
    }
    
    // MARK: - Latency Tests
    
    func testZeroLatency() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 0
        )
        
        XCTAssertEqual(reviewLog.latencyMs, 0)
    }
    
    func testHighLatency() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 2,
            nextStep: 0,
            result: false,
            latencyMs: 60000 // 1 minute
        )
        
        XCTAssertEqual(reviewLog.latencyMs, 60000)
    }
    
    // MARK: - Codable Tests
    
    func testJSONEncodingAndDecoding() throws {
        let cardId = UUID()
        
        let originalReviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: 3,
            nextStep: 4,
            result: true,
            latencyMs: 7500
        )
        
        // Encode to JSON
        let jsonData = try JSONEncoder().encode(originalReviewLog)
        XCTAssertFalse(jsonData.isEmpty)
        
        // Decode from JSON
        let decodedReviewLog = try JSONDecoder().decode(ReviewLog.self, from: jsonData)
        
        // Verify all properties match
        XCTAssertEqual(decodedReviewLog.id, originalReviewLog.id)
        XCTAssertEqual(decodedReviewLog.cardId, originalReviewLog.cardId)
        XCTAssertEqual(decodedReviewLog.reviewedAt.timeIntervalSince1970, 
                      originalReviewLog.reviewedAt.timeIntervalSince1970, 
                      accuracy: 1.0)
        XCTAssertEqual(decodedReviewLog.previousStep, originalReviewLog.previousStep)
        XCTAssertEqual(decodedReviewLog.nextStep, originalReviewLog.nextStep)
        XCTAssertEqual(decodedReviewLog.result, originalReviewLog.result)
        XCTAssertEqual(decodedReviewLog.latencyMs, originalReviewLog.latencyMs)
    }
    
    func testMultipleReviewLogsJSONArray() throws {
        let cardId1 = UUID()
        let cardId2 = UUID()
        
        let reviewLogs = [
            ReviewLog(
                cardId: cardId1,
                
                previousStep: 0,
                nextStep: 1,
                result: true,
                latencyMs: 3000
            ),
            ReviewLog(
                cardId: cardId2,
                
                previousStep: 2,
                nextStep: 0,
                result: false,
                latencyMs: 8000
            )
        ]
        
        // Encode array to JSON
        let jsonData = try JSONEncoder().encode(reviewLogs)
        XCTAssertFalse(jsonData.isEmpty)
        
        // Decode array from JSON
        let decodedReviewLogs = try JSONDecoder().decode([ReviewLog].self, from: jsonData)
        
        XCTAssertEqual(decodedReviewLogs.count, 2)
        XCTAssertEqual(decodedReviewLogs[0].cardId, cardId1)
        XCTAssertEqual(decodedReviewLogs[1].cardId, cardId2)
        XCTAssertTrue(decodedReviewLogs[0].result)
        XCTAssertFalse(decodedReviewLogs[1].result)
    }
    
    // MARK: - Edge Case Tests
    
    func testMaxStepValues() {
        let cardId = UUID()
        
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: Int.max,
            nextStep: Int.max,
            result: true,
            latencyMs: Int.max
        )
        
        XCTAssertEqual(reviewLog.previousStep, Int.max)
        XCTAssertEqual(reviewLog.nextStep, Int.max)
        XCTAssertEqual(reviewLog.latencyMs, Int.max)
    }
    
    func testNegativeStepValues() {
        let cardId = UUID()
        
        // Even though negative steps don't make sense in the context,
        // the model should handle them without crashing
        let reviewLog = ReviewLog(
            cardId: cardId,
            
            previousStep: -1,
            nextStep: -2,
            result: false,
            latencyMs: 0
        )
        
        XCTAssertEqual(reviewLog.previousStep, -1)
        XCTAssertEqual(reviewLog.nextStep, -2)
    }
    
    // MARK: - Business Logic Tests
    
    func testReviewLogCreationForDifferentScenarios() {
        let cardId = UUID()
        
        // Scenario 1: First correct review
        let firstCorrect = ReviewLog(
            cardId: cardId,
            
            previousStep: 0,
            nextStep: 1,
            result: true,
            latencyMs: 5000
        )
        
        // Scenario 2: Advanced correct review
        let advancedCorrect = ReviewLog(
            cardId: cardId,
            
            previousStep: 4,
            nextStep: 5,
            result: true,
            latencyMs: 3000
        )
        
        // Scenario 3: Reset after incorrect
        let resetIncorrect = ReviewLog(
            cardId: cardId,
            
            previousStep: 3,
            nextStep: 0,
            result: false,
            latencyMs: 10000
        )
        
        XCTAssertEqual(firstCorrect.nextStep, firstCorrect.previousStep + 1)
        XCTAssertEqual(advancedCorrect.nextStep, advancedCorrect.previousStep + 1)
        XCTAssertEqual(resetIncorrect.nextStep, 0)
        XCTAssertFalse(resetIncorrect.result)
    }
    
    func testReviewLogForLearningAnalytics() {
        let cardId = UUID()
        
        // Fast correct answer (good retention)
        let fastCorrect = ReviewLog(
            cardId: cardId,
            
            previousStep: 2,
            nextStep: 3,
            result: true,
            latencyMs: 1500
        )
        
        // Slow correct answer (struggling but correct)
        let slowCorrect = ReviewLog(
            cardId: cardId,
            
            previousStep: 1,
            nextStep: 2,
            result: true,
            latencyMs: 15000
        )
        
        // Both should advance steps when correct
        XCTAssertTrue(fastCorrect.result)
        XCTAssertTrue(slowCorrect.result)
        XCTAssertEqual(fastCorrect.nextStep, fastCorrect.previousStep + 1)
        XCTAssertEqual(slowCorrect.nextStep, slowCorrect.previousStep + 1)
        
        // But latency difference should be preserved for analytics
        XCTAssertLessThan(fastCorrect.latencyMs, slowCorrect.latencyMs)
    }
}
