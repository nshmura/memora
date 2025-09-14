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
        
        let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
        var calendar = Calendar.current
        calendar.timeZone = jstTimeZone
        
        let startOfDay = calendar.startOfDay(for: baseDate)
        return calendar.date(byAdding: .day, value: dayOffset, to: startOfDay) ?? startOfDay
    }
    
    static func startOfDay(for date: Date, in timeZone: TimeZone = TimeZone(identifier: "Asia/Tokyo")!) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        return calendar.startOfDay(for: date)
    }
}
