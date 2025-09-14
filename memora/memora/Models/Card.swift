//
//  Card.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

struct Card: Codable, Identifiable {
    let id: UUID
    var question: String
    var answer: String
    var stepIndex: Int
    var nextDue: Date
    var reviewCount: Int
    var lastResult: Bool?
    var tags: [String]
    
    init(question: String, answer: String, tags: [String] = []) {
        self.id = UUID()
        self.question = question
        self.answer = answer
        self.stepIndex = 0
        self.nextDue = Date()
        self.reviewCount = 0
        self.lastResult = nil
        self.tags = tags
    }
}
