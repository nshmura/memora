//
//  Scheduler.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

class Scheduler {
    static func gradeCard(_ card: Card, isCorrect: Bool, at date: Date = Date()) -> Card {
        var updatedCard = card
        updatedCard.reviewCount += 1
        updatedCard.lastResult = isCorrect
        
        if isCorrect {
            // Advance to next step
            updatedCard.stepIndex += 1
        } else {
            // Reset to step 0
            updatedCard.stepIndex = 0
        }
        
        updatedCard.nextDue = calculateNextDue(stepIndex: updatedCard.stepIndex, baseDate: date)
        return updatedCard
    }
    
    static func calculateNextDue(stepIndex: Int, baseDate: Date = Date()) -> Date {
        let intervals = [0, 1, 2, 4, 7, 15, 30]
        let dayOffset = stepIndex < intervals.count ? intervals[stepIndex] : intervals.last!
        
        // Use DateUtility for proper JST handling
        return DateUtility.addDays(to: baseDate, days: dayOffset)
    }
}
