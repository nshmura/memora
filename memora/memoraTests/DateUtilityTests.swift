import XCTest
@testable import memora

class DateUtilityTestsFixed: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Clear any previous timezone settings
        NSTimeZone.resetSystemTimeZone()
    }
    
    // MARK: - Test Basic Date Operations
    
    func testJSTTimeZone() {
        let timeZone = DateUtility.jstTimeZone
        XCTAssertEqual(timeZone.identifier, "Asia/Tokyo", "Should return Asia/Tokyo timezone")
    }
    
    func testJSTCalendar() {
        let calendar = DateUtility.jstCalendar
        XCTAssertEqual(calendar.timeZone.identifier, "Asia/Tokyo", "Calendar should use JST timezone")
        XCTAssertEqual(calendar.identifier, .gregorian, "Should use Gregorian calendar")
    }
    
    // MARK: - Test Start/End of Day
    
    func testStartOfDay() {
        // Create a test date: 2024-02-15 14:30:45 JST
        guard let testDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 15, hour: 14, minute: 30, second: 45) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let startOfDay = DateUtility.startOfDay(for: testDate)
        let jstCalendar = DateUtility.jstCalendar
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
        guard let testDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 15, hour: 14, minute: 30, second: 45) else {
            XCTFail("Failed to create test date")
            return
        }
        
        let endOfDay = DateUtility.endOfDay(for: testDate)
        let jstCalendar = DateUtility.jstCalendar
        let endComponents = jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: endOfDay)
        
        XCTAssertEqual(endComponents.year, 2024)
        XCTAssertEqual(endComponents.month, 2)
        XCTAssertEqual(endComponents.day, 15)
        XCTAssertEqual(endComponents.hour, 23)
        XCTAssertEqual(endComponents.minute, 59)
        XCTAssertEqual(endComponents.second, 59)
    }
    
    // MARK: - Test Date Arithmetic
    
    func testAddDays() {
        guard let baseDate = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 12, minute: 0, second: 0) else {
            XCTFail("Failed to create base date")
            return
        }
        
        // Test adding positive days
        let futureDate = DateUtility.addDays(to: baseDate, days: 5)
        let futureComponents = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: futureDate)
        XCTAssertEqual(futureComponents.year, 2024)
        XCTAssertEqual(futureComponents.month, 3)
        XCTAssertEqual(futureComponents.day, 20)
        
        // Test subtracting days
        let pastDate = DateUtility.addDays(to: baseDate, days: -10)
        let pastComponents = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: pastDate)
        XCTAssertEqual(pastComponents.year, 2024)
        XCTAssertEqual(pastComponents.month, 3)
        XCTAssertEqual(pastComponents.day, 5)
        
        // Test adding zero days
        let sameDate = DateUtility.addDays(to: baseDate, days: 0)
        XCTAssertEqual(sameDate.timeIntervalSince1970, DateUtility.startOfDay(for: baseDate).timeIntervalSince1970, accuracy: 0.001)
    }
    
    func testAddDaysAcrossMonthBoundary() {
        // February 28, 2024 (leap year) + 2 days = March 1, 2024
        guard let febDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 28, hour: 12, minute: 0, second: 0) else {
            XCTFail("Failed to create February date")
            return
        }
        
        let marchDate = DateUtility.addDays(to: febDate, days: 2)
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: marchDate)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 3)
        XCTAssertEqual(components.day, 1)
    }
    
    func testAddDaysAcrossYearBoundary() {
        // December 30, 2023 + 5 days = January 4, 2024
        guard let decDate = DateUtility.createJSTDate(year: 2023, month: 12, day: 30, hour: 15, minute: 0, second: 0) else {
            XCTFail("Failed to create December date")
            return
        }
        
        let janDate = DateUtility.addDays(to: decDate, days: 5)
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: janDate)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 4)
    }
    
    // MARK: - Test Same Day Comparison
    
    func testIsSameDay() {
        guard let date1 = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 10, minute: 30, second: 0),
              let date2 = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 23, minute: 59, second: 59),
              let differentDate = DateUtility.createJSTDate(year: 2024, month: 3, day: 16, hour: 0, minute: 0, second: 1) else {
            XCTFail("Failed to create test dates")
            return
        }
        
        XCTAssertTrue(DateUtility.isSameDay(date1, date2), "Same day at different times should be equal")
        XCTAssertFalse(DateUtility.isSameDay(date1, differentDate), "Different days should not be equal")
    }
    
    // MARK: - Test Days Between
    
    func testDaysBetween() {
        guard let startDate = DateUtility.createJSTDate(year: 2024, month: 3, day: 10, hour: 12, minute: 0, second: 0),
              let endDate = DateUtility.createJSTDate(year: 2024, month: 3, day: 15, hour: 18, minute: 30, second: 0) else {
            XCTFail("Failed to create test dates")
            return
        }
        
        let days = DateUtility.daysBetween(from: startDate, to: endDate)
        XCTAssertEqual(days, 5)
        
        // Test reverse
        let reverseDays = DateUtility.daysBetween(from: endDate, to: startDate)
        XCTAssertEqual(reverseDays, -5)
        
        // Test same day
        let sameDays = DateUtility.daysBetween(from: startDate, to: startDate)
        XCTAssertEqual(sameDays, 0)
    }
    
    // MARK: - Test Due Date Logic
    
    func testIsDue() {
        let now = Date()
        let yesterday = DateUtility.addDays(to: now, days: -1)
        let tomorrow = DateUtility.addDays(to: now, days: 1)
        
        XCTAssertTrue(DateUtility.isDue(yesterday), "Yesterday should be due")
        XCTAssertTrue(DateUtility.isDue(now), "Now should be due")
        XCTAssertFalse(DateUtility.isDue(tomorrow), "Tomorrow should not be due")
    }
    
    // MARK: - Test Critical JST Boundary Cases
    
    func testGetNextDayBase_NormalTime() {
        // Test normal time (10:00 AM)
        guard let morningDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 10, minute: 0, second: 0) else {
            XCTFail("Failed to create morning date")
            return
        }
        
        let nextDay = DateUtility.getNextDayBase(from: morningDate)
        
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15) // Should remain same day
    }
    
    func testGetNextDayBase_Midnight() {
        // Test midnight (00:00:00)
        guard let midnightDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 0, minute: 0, second: 0) else {
            XCTFail("Failed to create midnight date")
            return
        }
        
        let nextDay = DateUtility.getNextDayBase(from: midnightDate)
        
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15) // Should remain same day
    }
    
    func testGetNextDayBase_LateNight() {
        // Test late night (23:59)
        guard let lateNightDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 23, minute: 59, second: 59) else {
            XCTFail("Failed to create late night date")
            return
        }
        
        let nextDay = DateUtility.getNextDayBase(from: lateNightDate)
        
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day], from: nextDay)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 16) // Should move to next day
    }
    
    // MARK: - Test Date Creation
    
    func testCreateJSTDate() {
        guard let testDate = DateUtility.createJSTDate(year: 2024, month: 6, day: 15, hour: 14, minute: 30, second: 45) else {
            XCTFail("Failed to create JST date")
            return
        }
        
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: testDate)
        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 14)
        XCTAssertEqual(components.minute, 30)
        XCTAssertEqual(components.second, 45)
    }
    
    func testCreateJSTDate_InvalidDate() {
        // Test invalid date (February 30)
        let invalidDate = DateUtility.createJSTDate(year: 2024, month: 2, day: 30)
        XCTAssertNil(invalidDate, "Invalid date should return nil")
    }
    
    // MARK: - Test Critical Year Transition
    
    func testNewYearTransition() {
        // Test December 31, 2024 23:59:00 JST -> January 1, 2025
        guard let almostMidnight = DateUtility.createJSTDate(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 0) else {
            XCTFail("Failed to create New Year's Eve date")
            return
        }
        
        let nextDayStart = DateUtility.getNextDayBase(from: almostMidnight)
        
        let components = DateUtility.jstCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: nextDayStart)
        XCTAssertEqual(components.year, 2025) // Should be next year
        XCTAssertEqual(components.month, 1)   // January
        XCTAssertEqual(components.day, 1)     // 1st day
    }
    
    // MARK: - Test Thread Safety
    
    func testConcurrentAccess() {
        // Test that multiple threads can safely access DateUtility methods
        let expectation = self.expectation(description: "All threads completed")
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        
        for _ in 0..<10 {
            group.enter()
            queue.async {
                let date1 = Date()
                let date2 = Date()
                _ = DateUtility.isSameDay(date1, date2)
                _ = DateUtility.startOfDay(for: date1)
                _ = DateUtility.addDays(to: date1, days: 1)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
    }
}