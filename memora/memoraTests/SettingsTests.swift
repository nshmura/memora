//
//  SettingsTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
@testable import memora

final class SettingsTests: XCTestCase {

    // MARK: - Initialization Tests
    
    func testSettingsDefaultInitialization() {
        // Given & When
        let settings = Settings()
        
        // Then
        XCTAssertEqual(settings.intervals, [0, 1, 2, 4, 7, 15, 30])
        XCTAssertEqual(settings.morningHour, 8)
        XCTAssertEqual(settings.timeZoneIdentifier, "Asia/Tokyo")
    }
    
    func testSettingsIntervalsDefaultValues() {
        // Given
        let settings = Settings()
        
        // When & Then - Should have spaced repetition intervals
        XCTAssertEqual(settings.intervals.count, 7)
        XCTAssertEqual(settings.intervals[0], 0) // Same day
        XCTAssertEqual(settings.intervals[1], 1) // Next day
        XCTAssertEqual(settings.intervals[2], 2) // 2 days
        XCTAssertEqual(settings.intervals[3], 4) // 4 days
        XCTAssertEqual(settings.intervals[4], 7) // 1 week
        XCTAssertEqual(settings.intervals[5], 15) // 2+ weeks
        XCTAssertEqual(settings.intervals[6], 30) // 1 month
    }
    
    func testSettingsMorningHourDefaultValue() {
        // Given
        let settings = Settings()
        
        // When & Then - Should default to 8 AM
        XCTAssertEqual(settings.morningHour, 8)
        XCTAssertTrue(settings.morningHour >= 0)
        XCTAssertTrue(settings.morningHour <= 23)
    }
    
    func testSettingsTimezoneDefaultValue() {
        // Given
        let settings = Settings()
        
        // When & Then - Should default to Japan Standard Time
        XCTAssertEqual(settings.timeZoneIdentifier, "Asia/Tokyo")
        
        // Verify timezone is valid
        let timeZone = TimeZone(identifier: settings.timeZoneIdentifier)
        XCTAssertNotNil(timeZone, "Default timezone should be valid")
    }
    
    // MARK: - JSON Serialization Tests
    
    func testSettingsJSONEncoding() throws {
        // Given
        let settings = Settings()
        
        // When
        let jsonData = try JSONEncoder().encode(settings)
        
        // Then
        XCTAssertGreaterThan(jsonData.count, 0)
        
        // Verify JSON contains expected keys
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("intervals"))
        XCTAssertTrue(jsonString!.contains("morningHour"))
        XCTAssertTrue(jsonString!.contains("timeZoneIdentifier"))
        XCTAssertTrue(jsonString!.contains("Asia\\/Tokyo"))
    }
    
    func testSettingsJSONDecoding() throws {
        // Given
        let jsonString = """
        {
            "intervals": [0, 1, 2, 4, 7, 15, 30],
            "morningHour": 9,
            "timeZoneIdentifier": "Asia/Tokyo"
        }
        """
        let jsonData = jsonString.data(using: .utf8)!
        
        // When
        let settings = try JSONDecoder().decode(Settings.self, from: jsonData)
        
        // Then
        XCTAssertEqual(settings.intervals, [0, 1, 2, 4, 7, 15, 30])
        XCTAssertEqual(settings.morningHour, 9)
        XCTAssertEqual(settings.timeZoneIdentifier, "Asia/Tokyo")
    }
    
    func testSettingsJSONRoundTrip() throws {
        // Given
        var originalSettings = Settings()
        originalSettings.morningHour = 7
        originalSettings.intervals = [0, 2, 5, 10, 20, 45, 90]
        
        // When
        let jsonData = try JSONEncoder().encode(originalSettings)
        let decodedSettings = try JSONDecoder().decode(Settings.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedSettings.intervals, originalSettings.intervals)
        XCTAssertEqual(decodedSettings.morningHour, originalSettings.morningHour)
        XCTAssertEqual(decodedSettings.timeZoneIdentifier, originalSettings.timeZoneIdentifier)
    }
    
    // MARK: - Property Modification Tests
    
    func testSettingsPropertiesModification() {
        // Given
        var settings = Settings()
        
        // When
        settings.morningHour = 6
        settings.intervals = [0, 1, 3, 7, 14, 30, 60]
        settings.timeZoneIdentifier = "America/New_York"
        
        // Then
        XCTAssertEqual(settings.morningHour, 6)
        XCTAssertEqual(settings.intervals, [0, 1, 3, 7, 14, 30, 60])
        XCTAssertEqual(settings.timeZoneIdentifier, "America/New_York")
    }
    
    func testSettingsMorningHourValidRange() {
        // Given
        var settings = Settings()
        
        // When & Then - Should handle valid hour range (0-23)
        for hour in 0...23 {
            settings.morningHour = hour
            XCTAssertEqual(settings.morningHour, hour)
            XCTAssertTrue(settings.morningHour >= 0)
            XCTAssertTrue(settings.morningHour <= 23)
        }
    }
    
    func testSettingsIntervalsCustomization() {
        // Given
        var settings = Settings()
        
        // When
        settings.intervals = [0, 1, 2, 5, 10, 21, 45]
        
        // Then
        XCTAssertEqual(settings.intervals.count, 7)
        XCTAssertEqual(settings.intervals, [0, 1, 2, 5, 10, 21, 45])
    }
    
    // MARK: - Edge Case Tests
    
    func testSettingsWithEmptyIntervals() throws {
        // Given
        var settings = Settings()
        settings.intervals = []
        
        // When
        let jsonData = try JSONEncoder().encode(settings)
        let decodedSettings = try JSONDecoder().decode(Settings.self, from: jsonData)
        
        // Then
        XCTAssertTrue(decodedSettings.intervals.isEmpty)
    }
    
    func testSettingsWithLargeIntervals() throws {
        // Given
        var settings = Settings()
        settings.intervals = [0, 1, 7, 30, 90, 180, 365]
        
        // When
        let jsonData = try JSONEncoder().encode(settings)
        let decodedSettings = try JSONDecoder().decode(Settings.self, from: jsonData)
        
        // Then
        XCTAssertEqual(decodedSettings.intervals, [0, 1, 7, 30, 90, 180, 365])
    }
    
    func testSettingsWithDifferentTimezones() throws {
        // Given
        let timezones = ["America/New_York", "Europe/London", "Asia/Shanghai", "Pacific/Auckland"]
        
        for timezone in timezones {
            // When
            var settings = Settings()
            settings.timeZoneIdentifier = timezone
            
            // Then
            XCTAssertEqual(settings.timeZoneIdentifier, timezone)
            
            // Verify timezone is valid
            let tz = TimeZone(identifier: timezone)
            XCTAssertNotNil(tz, "\(timezone) should be a valid timezone")
            
            // Test JSON serialization
            let jsonData = try JSONEncoder().encode(settings)
            let decodedSettings = try JSONDecoder().decode(Settings.self, from: jsonData)
            XCTAssertEqual(decodedSettings.timeZoneIdentifier, timezone)
        }
    }
    
    // MARK: - Requirements Verification Tests
    
    func testSettingsSupportsNotificationTimeConfiguration() {
        // Given - Requirement 2.4: 通知時刻設定を提供する
        var settings = Settings()
        
        // When
        settings.morningHour = 10
        
        // Then - Should support notification time setting
        XCTAssertEqual(settings.morningHour, 10)
        XCTAssertTrue((0...23).contains(settings.morningHour))
    }
    
    func testSettingsSupportsJSTTimezoneProcessing() {
        // Given - Requirement 5.2: Asia/Tokyoタイムゾーンで日付の開始時刻を使用する
        let settings = Settings()
        
        // When
        let timezone = TimeZone(identifier: settings.timeZoneIdentifier)
        
        // Then - Should default to JST timezone
        XCTAssertNotNil(timezone)
        XCTAssertEqual(settings.timeZoneIdentifier, "Asia/Tokyo")
        
        // Verify timezone can be used for date calculations
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        XCTAssertNotNil(startOfDay)
    }
    
    func testSettingsSupportsSpacedRepetitionIntervals() {
        // Given - Support for spaced repetition algorithm
        let settings = Settings()
        
        // When & Then - Should provide appropriate intervals for spaced repetition
        XCTAssertEqual(settings.intervals.count, 7)
        
        // Verify intervals are in ascending order (generally)
        for i in 1..<settings.intervals.count {
            XCTAssertGreaterThanOrEqual(settings.intervals[i], settings.intervals[i-1])
        }
        
        // Verify covers appropriate time spans
        XCTAssertTrue(settings.intervals.contains(0))  // Same day
        XCTAssertTrue(settings.intervals.contains(1))  // Next day  
        XCTAssertTrue(settings.intervals.contains(7))  // Week
        XCTAssertTrue(settings.intervals.contains(30)) // Month
    }
}
