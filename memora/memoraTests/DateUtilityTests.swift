import XCTest
@testable import memora

class DateUtilityTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any previous timezone settings
        NSTimeZone.resetSystemTimeZone()
    }
    
    // MARK: - Test Basic Date Operations
    
    func testCurrentJSTDate() {
        let jstDate = DateUtility.currentJSTDate()
        let jstTimeZone = TimeZone(identifier: "Asia/Tokyo")!
        
        // Verify the date is recent (within 1 minute)
        let now = Date()
        let timeDifference = abs(jstDate.timeIntervalSince(now))
        XCTAssertLessThan(timeDifference, 60, "JST date should be within 60 seconds of system date")
        
        // Verify we can format it in JST
        let formatter = DateFormatter()
        formatter.timeZone = jstTimeZone
        formatter.dateStyle = .medium
        let jstString = formatter.string(from: jstDate)
        XCTAssertFalse(jstString.isEmpty, "Should be able to format JST date")
    }
    
    func testJSTTimeZone() {
        let timeZone = DateUtility.jstTimeZone()
        XCTAssertEqual(timeZone.identifier, "Asia/Tokyo", "Should return Asia/Tokyo timezone")
    }
    
    // MARK: - Test Start/End of Day
    
    func testStartOfDay() {
        // Create a test date: 2024-02-15 14:30:45 JST
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.second = 45
        components.timeZone = DateUtility.jstTimeZone()
        
        let testDate = Calendar(identifier: .gregorian).date(from: components)!
        let startOfDay = DateUtility.startOfDay(for: testDate)
        
        // Verify start of day
        let jstCalendar = DateUtility.jstCalendar()
        let startComponents = jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startOfDay)
        
        XCTAssertEqual(startComponents.year, 2024)
        XCTAssertEqual(startComponents.month, 2)
        XCTAssertEqual(startComponents.day, 15)
        XCTAssertEqual(startComponents.hour, 0)
        XCTAssertEqual(startComponents.minute, 0)
        XCTAssertEqual(startComponents.second, 0)
    }
    
    func testEndOfDay() {
        // Create a test date: 2024-02-15 14:30:45 JST
        var components = DateComponents()
        components.year = 2024
        components.month = 2
        components.day = 15
        components.hour = 14
        components.minute = 30
        components.second = 45
        components.timeZone = DateUtility.jstTimeZone()
        
        let testDate = Calendar(identifier: .gregorian).date(from: components)!
        let endOfDay = DateUtility.endOfDay(for: testDate)
        
        // Verify end of day (23:59:59.999)
        let jstCalendar = DateUtility.jstCalendar()
        let endComponents = jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: endOfDay)
        
        XCTAssertEqual(endComponents.year, 2024)
        XCTAssertEqual(endComponents.month, 2)
        XCTAssertEqual(endComponents.day, 15)
        XCTAssertEqual(endComponents.hour, 23)
        XCTAssertEqual(endComponents.minute, 59)
        XCTAssertEqual(endComponents.second, 59)
        // Nanosecond should be close to 999,999,999 (but may vary slightly)
        XCTAssertGreaterThan(endComponents.nanosecond ?? 0, 999_000_000)
    }
    
    // MARK: - Test Date Arithmetic
    
    func testAddDays() {
        // Create base date: 2024-02-15 JST
        let baseDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 15, hour: 10, minute: 0, second: 0)
        
        // Test adding positive days
        let futureDate = DateUtility.addDays(to: baseDate, days: 5)
        let futureComponents = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: futureDate)
        XCTAssertEqual(futureComponents.day, 20)
        XCTAssertEqual(futureComponents.month, 2)
        XCTAssertEqual(futureComponents.year, 2024)
        
        // Test adding negative days
        let pastDate = DateUtility.addDays(to: baseDate, days: -10)
        let pastComponents = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: pastDate)
        XCTAssertEqual(pastComponents.day, 5)
        XCTAssertEqual(pastComponents.month, 2)
        XCTAssertEqual(pastComponents.year, 2024)
        
        // Test adding zero days
        let sameDate = DateUtility.addDays(to: baseDate, days: 0)
        XCTAssertEqual(sameDate.timeIntervalSince1970, baseDate.timeIntervalSince1970, accuracy: 0.001)
    }
    
    func testAddDaysAcrossMonthBoundary() {
        // Test February to March
        let febDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 28, hour: 12, minute: 0, second: 0)
        let marchDate = DateUtility.addDays(to: febDate, days: 2)
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: marchDate)
        
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 1) // 2024 is leap year, so Feb 29 exists
    }
    
    func testAddDaysAcrossYearBoundary() {
        let decDate = DateUtility.createJSTDate(year: 2023, month: 12, day: 30, hour: 15, minute: 0, second: 0)
        let janDate = DateUtility.addDays(to: decDate, days: 5)
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: janDate)
        
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 4)
    }
    
    // MARK: - Test Date Comparison
    
    func testIsSameDay() {
        let date1 = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 9, minute: 0, second: 0)
        let date2 = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 23, minute: 59, second: 59)
        let differentDate = DateUtility.createJSTDate(year: 2024, month: 3, day: 16, hour: 0, minute: 0, second: 1)
        
        XCTAssertTrue(DateUtility.isSameDay(date1, date2), "Same day at different times should be equal")
        XCTAssertFalse(DateUtility.isSameDay(date1, differentDate), "Different days should not be equal")
    }
    
    func testDaysBetween() {
        let startDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 10, hour: 14, minute: 0, second: 0)
        let endDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 15, hour: 8, minute: 0, second: 0)
        
        let days = DateUtility.daysBetween(from: startDate, to: endDate)
        XCTAssertEqual(days, 5, "Should be 5 days between Feb 10 and Feb 15")
        
        // Test reverse
        let reverseDays = DateUtility.daysBetween(from: endDate, to: startDate)
        XCTAssertEqual(reverseDays, -5, "Reverse should be -5 days")
        
        // Test same day
        let sameDays = DateUtility.daysBetween(from: startDate, to: startDate)
        XCTAssertEqual(sameDays, 0, "Same date should be 0 days")
    }
    
    // MARK: - Test isDue Method
    
    func testIsDue() {
        let now = DateUtility.currentJSTDate()
        let yesterday = DateUtility.addDays(to: now, days: -1)
        let tomorrow = DateUtility.addDays(to: now, days: 1)
        
        XCTAssertTrue(DateUtility.isDue(yesterday, referenceDate: now), "Yesterday should be due")
        XCTAssertTrue(DateUtility.isDue(now, referenceDate: now), "Now should be due")
        XCTAssertFalse(DateUtility.isDue(tomorrow, referenceDate: now), "Tomorrow should not be due")
    }
    
    // MARK: - Test Next Day Boundary Calculations
    
    func testGetNextDayBase() {
        // Test regular case: 10:00 AM should return start of next day
        let morningDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 10, minute: 0, second: 0)
        let nextDay = DateUtility.getNextDayBase(from: morningDate)
        
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 16)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testGetNextDayBaseAtMidnight() {
        // Test edge case: exactly midnight
        let midnightDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 0, minute: 0, second: 0)
        let nextDay = DateUtility.getNextDayBase(from: midnightDate)
        
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 16)
    }
    
    func testGetNextDayBaseNearMidnight() {
        // Test edge case: 23:59:59 JST - should go to start of day after tomorrow
        let lateNightDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 23, minute: 59, second: 59)
        let nextDay = DateUtility.getNextDayBase(from: lateNightDate)
        
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 16)
    }
    
    // MARK: - Test Calendar and Formatter Methods
    
    func testJSTCalendar() {
        let calendar = DateUtility.jstCalendar()
        XCTAssertEqual(calendar.timeZone.identifier, "Asia/Tokyo")
        XCTAssertEqual(calendar.identifier, .gregorian)
    }
    
    func testJSTDateFormatter() {
        let formatter = DateUtility.jstDateFormatter()
        XCTAssertEqual(formatter.timeZone?.identifier, "Asia/Tokyo")
        XCTAssertEqual(formatter.dateStyle, .medium)
        XCTAssertEqual(formatter.timeStyle, .none)
    }
    
    func testFormatDateJST() {
        let testDate = DateUtility.createJSTDate(year: 2024, month: 7, day: 4, hour: 15, minute: 30, second: 0)
        let formatted = DateUtility.formatDateJST(testDate)
        
        // The exact format might vary by locale, but it should contain the date components
        XCTAssertTrue(formatted.contains("2024") || formatted.contains("24"), "Should contain year")
        XCTAssertTrue(formatted.contains("7") || formatted.contains("Jul"), "Should contain month")
        XCTAssertTrue(formatted.contains("4"), "Should contain day")
    }
    
    // MARK: - Test Date Creation Helper
    
    func testCreateJSTDate() {
        let date = DateUtility.createJSTDate(year: 2024, month: 8, day: 20, hour: 14, minute: 45, second: 30)
        
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 8)
        XCTAssertEqual(components.day, 20)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 45)
        XCTAssertEqual(components.second, 30)
    }
    
    // MARK: - Test Edge Cases and Requirements
    
    func testMidnightBoundaryHandling() {
        // Test Requirement 5.1: Handle 23:59 JST boundary correctly
        let almostMidnight = DateUtility.createJSTDate(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 0)
        let nextDayStart = DateUtility.getNextDayBase(from: almostMidnight)
        
        // Should advance to start of next day (and next year)
        let components = DateUtility.jstCalendar().dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDayStart)
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }
    
    func testTimezoneConsistency() {
        // Test Requirement 5.2: Ensure all date operations use Asia/Tokyo
        let date1 = DateUtility.currentJSTDate()
        let date2 = DateUtility.addDays(to: date1, days: 1)
        let startOfDay = DateUtility.startOfDay(for: date2)
        let endOfDay = DateUtility.endOfDay(for: date2)
        
        // All operations should maintain JST timezone consistency
        // This is verified by the fact that our date calculations work correctly
        // regardless of the system timezone
        
        let dayDifference = DateUtility.daysBetween(from: date1, to: date2)
        XCTAssertEqual(dayDifference, 1, "Adding 1 day should result in 1 day difference")
        
        XCTAssertTrue(DateUtility.isSameDay(date2, startOfDay), "Added day and its start should be same day")
        XCTAssertTrue(DateUtility.isSameDay(date2, endOfDay), "Added day and its end should be same day")
    }
}