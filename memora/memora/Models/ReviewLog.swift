//
//  ReviewLog.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

struct ReviewLog: Codable, Identifiable {
    let id: UUID
    let cardId: UUID
    let reviewedAt: Date
    let previousStep: Int
    let nextStep: Int
    let result: Bool
    let latencyMs: Int
    
    init(cardId: UUID, previousStep: Int, nextStep: Int, result: Bool, latencyMs: Int) {
        self.id = UUID()
        self.cardId = cardId
        self.reviewedAt = Date()
        self.previousStep = previousStep
        self.nextStep = nextStep
        self.result = result
        self.latencyMs = latencyMs
    }
}
