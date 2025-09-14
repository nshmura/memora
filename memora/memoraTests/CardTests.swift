//
//  CardTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
@testable import memora

final class CardTests: XCTestCase {

    // MARK: - Initialization Tests
    
    func testCardInitialization() {
        // Given
        let question = "What is the capital of Japan?"
        let answer = "Tokyo"
        let tags = ["geography", "japan"]
        
        // When
        let card = Card(question: question, answer: answer, tags: tags)
        
        // Then
        XCTAssertEqual(card.question, question)
        XCTAssertEqual(card.answer, answer)
        XCTAssertEqual(card.tags, tags)
        XCTAssertEqual(card.stepIndex, 0)
        XCTAssertEqual(card.reviewCount, 0)
        XCTAssertNil(card.lastResult)
        XCTAssertNotNil(card.id)
        XCTAssertNotNil(card.nextDue)
    }
    
    func testCardInitializationWithoutTags() {
        // Given
        let question = "Test question"
        let answer = "Test answer"
        
        // When
        let card = Card(question: question, answer: answer)
        
        // Then
        XCTAssertEqual(card.question, question)
        XCTAssertEqual(card.answer, answer)
        XCTAssertTrue(card.tags.isEmpty)
        XCTAssertEqual(card.stepIndex, 0)
        XCTAssertEqual(card.reviewCount, 0)
        XCTAssertNil(card.lastResult)
    }
    
    func testCardUniqueIDs() {
        // Given & When
        let card1 = Card(question: "Q1", answer: "A1")
        let card2 = Card(question: "Q2", answer: "A2")
        
        // Then
        XCTAssertNotEqual(card1.id, card2.id)
    }
    
    // MARK: - JSON Serialization Tests
    
    func testCardJSONEncoding() throws {
        // Given
        let card = Card(question: "Test Question", answer: "Test Answer", tags: ["test", "unit"])
        
        // When
        let jsonData = try JSONEncoder().encode(card)
        
        // Then
        XCTAssertNotNil(jsonData)
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // Verify JSON contains expected fields
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("Test Question"))
        XCTAssertTrue(jsonString!.contains("Test Answer"))
        XCTAssertTrue(jsonString!.contains("test"))
        XCTAssertTrue(jsonString!.contains("unit"))
    }
    
    func testCardJSONDecoding() throws {
        // Given
        let originalCard = Card(question: "Original Question", answer: "Original Answer", tags: ["original"])
        let jsonData = try JSONEncoder().encode(originalCard)
        
        // When
        let decodedCard = try JSONDecoder().decode(Card.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedCard.id, originalCard.id)
        XCTAssertEqual(decodedCard.question, originalCard.question)
        XCTAssertEqual(decodedCard.answer, originalCard.answer)
        XCTAssertEqual(decodedCard.stepIndex, originalCard.stepIndex)
        XCTAssertEqual(decodedCard.reviewCount, originalCard.reviewCount)
        XCTAssertEqual(decodedCard.lastResult, originalCard.lastResult)
        XCTAssertEqual(decodedCard.tags, originalCard.tags)
        XCTAssertEqual(decodedCard.nextDue.timeIntervalSince1970, 
                      originalCard.nextDue.timeIntervalSince1970, accuracy: 0.001)
    }
    
    func testCardJSONRoundTrip() throws {
        // Given
        let originalCard = Card(question: "Round Trip Test", answer: "Success", tags: ["json", "test"])
        
        // When
        let jsonData = try JSONEncoder().encode(originalCard)
        let decodedCard = try JSONDecoder().decode(Card.self, from: jsonData)
        let reEncodedData = try JSONEncoder().encode(decodedCard)
        let finalCard = try JSONDecoder().decode(Card.self, from: reEncodedData)
        
        // Then
        XCTAssertEqual(finalCard.id, originalCard.id)
        XCTAssertEqual(finalCard.question, originalCard.question)
        XCTAssertEqual(finalCard.answer, originalCard.answer)
        XCTAssertEqual(finalCard.tags, originalCard.tags)
    }
    
    // MARK: - Edge Cases Tests
    
    func testCardWithEmptyStrings() {
        // Given & When
        let card = Card(question: "", answer: "")
        
        // Then
        XCTAssertEqual(card.question, "")
        XCTAssertEqual(card.answer, "")
        XCTAssertTrue(card.tags.isEmpty)
    }
    
    func testCardWithLongStrings() {
        // Given
        let longQuestion = String(repeating: "Q", count: 1000)
        let longAnswer = String(repeating: "A", count: 1000)
        let manyTags = (1...100).map { "tag\($0)" }
        
        // When
        let card = Card(question: longQuestion, answer: longAnswer, tags: manyTags)
        
        // Then
        XCTAssertEqual(card.question, longQuestion)
        XCTAssertEqual(card.answer, longAnswer)
        XCTAssertEqual(card.tags.count, 100)
    }
    
    func testCardWithSpecialCharacters() throws {
        // Given
        let specialQuestion = "What does 'こんにちは' mean? (日本語)"
        let specialAnswer = "Hello! 😊🇯🇵"
        let specialTags = ["日本語", "emoji", "unicode"]
        
        // When
        let card = Card(question: specialQuestion, answer: specialAnswer, tags: specialTags)
        
        // Then - Should handle JSON encoding/decoding with special characters
        let jsonData = try JSONEncoder().encode(card)
        let decodedCard = try JSONDecoder().decode(Card.self, from: jsonData)
        
        XCTAssertEqual(decodedCard.question, specialQuestion)
        XCTAssertEqual(decodedCard.answer, specialAnswer)
        XCTAssertEqual(decodedCard.tags, specialTags)
    }
    
    func testCardPropertiesModification() {
        // Given
        var card = Card(question: "Original", answer: "Original")
        
        // When
        card.question = "Modified Question"
        card.answer = "Modified Answer"
        card.stepIndex = 3
        card.reviewCount = 5
        card.lastResult = true
        card.tags = ["modified", "test"]
        
        // Then
        XCTAssertEqual(card.question, "Modified Question")
        XCTAssertEqual(card.answer, "Modified Answer")
        XCTAssertEqual(card.stepIndex, 3)
        XCTAssertEqual(card.reviewCount, 5)
        XCTAssertEqual(card.lastResult, true)
        XCTAssertEqual(card.tags, ["modified", "test"])
    }
    
    // MARK: - Date Handling Tests
    
    func testCardDateSerialization() throws {
        // Given
        let specificDate = Date(timeIntervalSince1970: 1694692800) // 2023-09-14 12:00:00 UTC
        var card = Card(question: "Date Test", answer: "Test")
        card.nextDue = specificDate
        
        // When
        let jsonData = try JSONEncoder().encode(card)
        let decodedCard = try JSONDecoder().decode(Card.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedCard.nextDue.timeIntervalSince1970, 
                      specificDate.timeIntervalSince1970, accuracy: 0.001)
    }
}
