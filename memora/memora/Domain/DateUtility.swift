//
//  DateUtility.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

/// JST (Asia/Tokyo) timezone date utility functions
class DateUtility {
    
    /// JST timezone constant
    static let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
    
    /// JST calendar instance
    static var jstCalendar: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = jstTimeZone
        return calendar
    }
    
    // MARK: - Core Date Operations
    
    /// Get the start of day in JST timezone for the given date
    /// - Parameter date: The input date
    /// - Returns: Start of day (00:00:00) in JST timezone
    static func startOfDay(for date: Date) -> Date {
        return jstCalendar.startOfDay(for: date)
    }
    
    /// Get the end of day in JST timezone for the given date
    /// - Parameter date: The input date
    /// - Returns: End of day (23:59:59.999) in JST timezone
    static func endOfDay(for date: Date) -> Date {
        let startOfNextDay = jstCalendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) ?? date
        return jstCalendar.date(byAdding: .second, value: -1, to: startOfNextDay) ?? date
    }
    
    /// Add days to a date and return the start of that day in JST
    /// - Parameters:
    ///   - date: Base date
    ///   - days: Number of days to add (can be negative)
    /// - Returns: Start of day after adding specified days in JST
    static func addDays(to date: Date, days: Int) -> Date {
        let startOfBaseDay = startOfDay(for: date)
        return jstCalendar.date(byAdding: .day, value: days, to: startOfBaseDay) ?? startOfBaseDay
    }
    
    /// Check if two dates are the same day in JST timezone
    /// - Parameters:
    ///   - date1: First date
    ///   - date2: Second date
    /// - Returns: true if both dates are on the same JST day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return jstCalendar.isDate(date1, inSameDayAs: date2)
    }
    
    /// Check if a date is today in JST timezone
    /// - Parameter date: Date to check
    /// - Returns: true if the date is today in JST
    static func isToday(_ date: Date) -> Bool {
        return isSameDay(date, Date())
    }
    
    /// Check if a date is due (today or earlier) in JST timezone
    /// - Parameter date: Date to check
    /// - Returns: true if the date is due for review
    static func isDue(_ date: Date) -> Bool {
        let today = startOfDay(for: Date())
        let targetDay = startOfDay(for: date)
        return targetDay <= today
    }
    
    // MARK: - Date Boundary Handling
    
    /// Handle the critical 23:59 JST boundary case
    /// Ensures that learning at 23:59 JST correctly calculates next day as 00:00 JST
    /// - Parameter date: Current date/time
    /// - Returns: Appropriate base date for calculations
    static func getNextDayBase(from date: Date) -> Date {
        let jstHour = jstCalendar.component(.hour, from: date)
        
        // If it's very late (after 23:00), consider it as next day for scheduling
        if jstHour >= 23 {
            return addDays(to: date, days: 1)
        }
        
        return date
    }
    
    /// Get the number of days between two dates in JST
    /// - Parameters:
    ///   - from: Start date
    ///   - to: End date
    /// - Returns: Number of days difference (can be negative)
    static func daysBetween(from: Date, to: Date) -> Int {
        let fromStart = startOfDay(for: from)
        let toStart = startOfDay(for: to)
        
        let components = jstCalendar.dateComponents([.day], from: fromStart, to: toStart)
        return components.day ?? 0
    }
    
    // MARK: - Formatting Helpers
    
    /// Get a date formatter configured for JST
    /// - Returns: DateFormatter with JST timezone
    static func jstDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = jstTimeZone
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }
    
    /// Format date as JST string for debugging
    /// - Parameter date: Date to format
    /// - Returns: Formatted JST date string
    static func debugString(for date: Date) -> String {
        let formatter = jstDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss JST"
        return formatter.string(from: date)
    }
}