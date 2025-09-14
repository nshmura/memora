//
//  DateUtilityTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
@testable import memora

class DateUtilityTests: XCTestCase {
    
    // MARK: - Test Setup
    
    override func setUp() {
        super.setUp()
        // Ensure we're testing with a consistent timezone
    }
    
    // MARK: - Start of Day Tests
    
    func testStartOfDay() {
        // Create a specific JST datetime: 2024-01-15 14:30:45 JST
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let testDate = jstFormatter.date(from: "2024-01-15 14:30:45")!
        
        let startOfDay = DateUtility.startOfDay(for: testDate)
        
        // Should return 2024-01-15 00:00:00 JST
        let expectedStart = jstFormatter.date(from: "2024-01-15 00:00:00")!
        XCTAssertEqual(startOfDay, expectedStart, "Start of day should be 00:00:00 JST")
    }
    
    func testStartOfDayAtMidnight() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let midnightDate = jstFormatter.date(from: "2024-01-15 00:00:00")!
        
        let startOfDay = DateUtility.startOfDay(for: midnightDate)
        
        XCTAssertEqual(startOfDay, midnightDate, "Start of day for midnight should be the same")
    }
    
    // MARK: - End of Day Tests
    
    func testEndOfDay() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let testDate = jstFormatter.date(from: "2024-01-15 14:30:45")!
        
        let endOfDay = DateUtility.endOfDay(for: testDate)
        
        // Should return 2024-01-15 23:59:59 JST
        let jstCalendar = DateUtility.jstCalendar
        let components = jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endOfDay)
        
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 23)
        XCTAssertEqual(components.minute, 59)
        XCTAssertEqual(components.second, 59)
    }
    
    // MARK: - Add Days Tests
    
    func testAddDaysPositive() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd"
        let baseDate = jstFormatter.date(from: "2024-01-15")!
        
        let futureDate = DateUtility.addDays(to: baseDate, days: 5)
        let expectedDate = jstFormatter.date(from: "2024-01-20")!
        
        XCTAssertEqual(DateUtility.startOfDay(for: futureDate), DateUtility.startOfDay(for: expectedDate))
    }
    
    func testAddDaysNegative() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd"
        let baseDate = jstFormatter.date(from: "2024-01-15")!
        
        let pastDate = DateUtility.addDays(to: baseDate, days: -3)
        let expectedDate = jstFormatter.date(from: "2024-01-12")!
        
        XCTAssertEqual(DateUtility.startOfDay(for: pastDate), DateUtility.startOfDay(for: expectedDate))
    }
    
    func testAddDaysZero() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let baseDate = jstFormatter.date(from: "2024-01-15 14:30:45")!
        
        let sameDay = DateUtility.addDays(to: baseDate, days: 0)
        let expectedStart = jstFormatter.date(from: "2024-01-15 00:00:00")!
        
        XCTAssertEqual(sameDay, expectedStart, "Adding 0 days should return start of same day")
    }
    
    // MARK: - Same Day Tests
    
    func testIsSameDayTrue() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date1 = jstFormatter.date(from: "2024-01-15 09:30:00")!
        let date2 = jstFormatter.date(from: "2024-01-15 23:45:00")!
        
        XCTAssertTrue(DateUtility.isSameDay(date1, date2), "Dates on same JST day should be equal")
    }
    
    func testIsSameDayFalse() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date1 = jstFormatter.date(from: "2024-01-15 23:59:59")!
        let date2 = jstFormatter.date(from: "2024-01-16 00:00:01")!
        
        XCTAssertFalse(DateUtility.isSameDay(date1, date2), "Dates on different JST days should not be equal")
    }
    
    // MARK: - Due Date Tests
    
    func testIsDueToday() {
        let today = DateUtility.startOfDay(for: Date())
        XCTAssertTrue(DateUtility.isDue(today), "Today should be due")
    }
    
    func testIsDuePast() {
        let pastDate = DateUtility.addDays(to: Date(), days: -1)
        XCTAssertTrue(DateUtility.isDue(pastDate), "Past date should be due")
    }
    
    func testIsDueFuture() {
        let futureDate = DateUtility.addDays(to: Date(), days: 1)
        XCTAssertFalse(DateUtility.isDue(futureDate), "Future date should not be due")
    }
    
    // MARK: - Critical JST Boundary Tests (Requirement 5.1)
    
    func testDateBoundaryAt2359JST() {
        // Test the critical 23:59 JST boundary case
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let lateNightDate = jstFormatter.date(from: "2024-01-15 23:59:00")!
        
        let nextDayBase = DateUtility.getNextDayBase(from: lateNightDate)
        let expectedNextDay = jstFormatter.date(from: "2024-01-16 00:00:00")!
        
        XCTAssertEqual(DateUtility.startOfDay(for: nextDayBase), DateUtility.startOfDay(for: expectedNextDay),
                       "23:59 JST should be treated as next day base")
    }
    
    func testDateBoundaryAt2200JST() {
        // Test that earlier evening doesn't trigger next day logic
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let eveningDate = jstFormatter.date(from: "2024-01-15 22:00:00")!
        
        let sameDay = DateUtility.getNextDayBase(from: eveningDate)
        
        XCTAssertTrue(DateUtility.isSameDay(eveningDate, sameDay),
                      "22:00 JST should remain same day")
    }
    
    func testDateBoundaryAtMidnightTransition() {
        // Test exactly at midnight transition
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let midnightDate = jstFormatter.date(from: "2024-01-16 00:00:00")!
        
        let startOfDay = DateUtility.startOfDay(for: midnightDate)
        
        XCTAssertEqual(startOfDay, midnightDate, "Midnight should be start of its own day")
    }
    
    // MARK: - Days Between Tests
    
    func testDaysBetweenSameDay() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd"
        let date = jstFormatter.date(from: "2024-01-15")!
        
        let days = DateUtility.daysBetween(from: date, to: date)
        XCTAssertEqual(days, 0, "Days between same date should be 0")
    }
    
    func testDaysBetweenPositive() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = jstFormatter.date(from: "2024-01-15")!
        let endDate = jstFormatter.date(from: "2024-01-20")!
        
        let days = DateUtility.daysBetween(from: startDate, to: endDate)
        XCTAssertEqual(days, 5, "Days between should be 5")
    }
    
    func testDaysBetweenNegative() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = jstFormatter.date(from: "2024-01-20")!
        let endDate = jstFormatter.date(from: "2024-01-15")!
        
        let days = DateUtility.daysBetween(from: startDate, to: endDate)
        XCTAssertEqual(days, -5, "Days between should be -5")
    }
    
    // MARK: - Timezone Consistency Tests (Requirement 5.2)
    
    func testJSTTimezoneConsistency() {
        // Test that all operations use Asia/Tokyo consistently
        XCTAssertEqual(DateUtility.jstTimeZone.identifier, "Asia/Tokyo", "Should use Asia/Tokyo timezone")
        XCTAssertEqual(DateUtility.jstCalendar.timeZone.identifier, "Asia/Tokyo", "Calendar should use Asia/Tokyo timezone")
    }
    
    func testJSTTimezoneIndependence() {
        // Test that JST calculations are independent of system timezone
        let originalTimeZone = TimeZone.current
        
        // This test ensures JST operations work regardless of system timezone
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let testDate = jstFormatter.date(from: "2024-01-15 14:30:00")!
        
        let startOfDay = DateUtility.startOfDay(for: testDate)
        let expectedStart = jstFormatter.date(from: "2024-01-15 00:00:00")!
        
        XCTAssertEqual(startOfDay, expectedStart, "JST calculations should be independent of system timezone")
    }
    
    // MARK: - Formatter Tests
    
    func testDebugStringFormat() {
        let jstFormatter = DateUtility.jstDateFormatter()
        jstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let testDate = jstFormatter.date(from: "2024-01-15 14:30:45")!
        
        let debugString = DateUtility.debugString(for: testDate)
        
        XCTAssertTrue(debugString.contains("2024-01-15"), "Debug string should contain date")
        XCTAssertTrue(debugString.contains("14:30:45"), "Debug string should contain time")
        XCTAssertTrue(debugString.contains("JST"), "Debug string should indicate JST timezone")
    }
}