//
//  SettingsViewModelTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
import UserNotifications
@testable import memora

@MainActor
class SettingsViewModelTests: XCTestCase {
    var viewModel: SettingsViewModel!
    var mockStore: Store!
    
    override func setUp() {
        super.setUp()
        mockStore = Store()
        // Set up test settings
        var testSettings = Settings()
        testSettings.morningHour = 9
        testSettings.intervals = [0, 1, 2, 4, 7, 15, 30]
        mockStore.updateSettings(testSettings)
        
        viewModel = SettingsViewModel(store: mockStore)
    }
    
    override func tearDown() {
        viewModel = nil
        mockStore = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(viewModel.morningHour, 9)
        XCTAssertEqual(viewModel.intervals, [0, 1, 2, 4, 7, 15, 30])
        XCTAssertEqual(viewModel.notificationPermissionStatus, .notDetermined)
    }
    
    func testLoadSettings() {
        // Change store settings
        var newSettings = Settings()
        newSettings.morningHour = 10
        newSettings.intervals = [1, 2, 3, 5, 8, 13, 21]
        mockStore.updateSettings(newSettings)
        
        // Update store in viewModel
        viewModel.updateStore(mockStore)
        
        XCTAssertEqual(viewModel.morningHour, 10)
        XCTAssertEqual(viewModel.intervals, [1, 2, 3, 5, 8, 13, 21])
    }
    
    // MARK: - Morning Hour Tests
    
    func testUpdateMorningHour_ValidHour() {
        viewModel.updateMorningHour(14)
        
        XCTAssertEqual(viewModel.morningHour, 14)
        XCTAssertEqual(mockStore.settings.morningHour, 14)
    }
    
    func testUpdateMorningHour_BoundaryValues() {
        // Test lower boundary
        viewModel.updateMorningHour(0)
        XCTAssertEqual(viewModel.morningHour, 0)
        XCTAssertEqual(mockStore.settings.morningHour, 0)
        
        // Test upper boundary
        viewModel.updateMorningHour(23)
        XCTAssertEqual(viewModel.morningHour, 23)
        XCTAssertEqual(mockStore.settings.morningHour, 23)
    }
    
    func testUpdateMorningHour_InvalidHour() {
        let originalHour = viewModel.morningHour
        
        // Test negative value
        viewModel.updateMorningHour(-1)
        XCTAssertEqual(viewModel.morningHour, originalHour)
        
        // Test value over 23
        viewModel.updateMorningHour(24)
        XCTAssertEqual(viewModel.morningHour, originalHour)
        
        // Test very large value
        viewModel.updateMorningHour(100)
        XCTAssertEqual(viewModel.morningHour, originalHour)
    }
    
    // MARK: - Notification Permission Tests
    
    func testNotificationStatusString() {
        viewModel.notificationPermissionStatus = .notDetermined
        XCTAssertEqual(viewModel.notificationStatusString, "未設定")
        
        viewModel.notificationPermissionStatus = .denied
        XCTAssertEqual(viewModel.notificationStatusString, "拒否")
        
        viewModel.notificationPermissionStatus = .authorized
        XCTAssertEqual(viewModel.notificationStatusString, "許可")
        
        viewModel.notificationPermissionStatus = .provisional
        XCTAssertEqual(viewModel.notificationStatusString, "仮許可")
        
        viewModel.notificationPermissionStatus = .ephemeral
        XCTAssertEqual(viewModel.notificationStatusString, "一時許可")
    }
    
    func testCanReceiveNotifications() {
        viewModel.notificationPermissionStatus = .notDetermined
        XCTAssertFalse(viewModel.canReceiveNotifications)
        
        viewModel.notificationPermissionStatus = .denied
        XCTAssertFalse(viewModel.canReceiveNotifications)
        
        viewModel.notificationPermissionStatus = .authorized
        XCTAssertTrue(viewModel.canReceiveNotifications)
        
        viewModel.notificationPermissionStatus = .provisional
        XCTAssertFalse(viewModel.canReceiveNotifications)
    }
    
    // MARK: - Helper Properties Tests
    
    func testMorningTimeString() {
        viewModel.morningHour = 8
        let timeString = viewModel.morningTimeString
        
        // Should contain the hour in some format
        XCTAssertTrue(timeString.contains("8") || timeString.contains("08"))
    }
    
    func testMorningTimeString_DifferentHours() {
        // Test various hours
        for hour in [0, 1, 9, 12, 15, 23] {
            viewModel.morningHour = hour
            let timeString = viewModel.morningTimeString
            
            // Should not be empty and should contain hour information
            XCTAssertFalse(timeString.isEmpty)
            XCTAssertTrue(timeString.contains("\(hour)") || timeString.contains(String(format: "%02d", hour)))
        }
    }
    
    // MARK: - Store Integration Tests
    
    func testStoreIntegration_SettingsUpdate() {
        let originalSettings = mockStore.settings
        
        viewModel.updateMorningHour(15)
        
        // Verify settings were updated in store
        XCTAssertNotEqual(mockStore.settings.morningHour, originalSettings.morningHour)
        XCTAssertEqual(mockStore.settings.morningHour, 15)
        
        // Verify other settings remain unchanged
        XCTAssertEqual(mockStore.settings.intervals, originalSettings.intervals)
        XCTAssertEqual(mockStore.settings.timeZoneIdentifier, originalSettings.timeZoneIdentifier)
    }
    
    // MARK: - Edge Cases Tests
    
    func testMultipleHourUpdates() {
        viewModel.updateMorningHour(10)
        XCTAssertEqual(viewModel.morningHour, 10)
        
        viewModel.updateMorningHour(15)
        XCTAssertEqual(viewModel.morningHour, 15)
        
        viewModel.updateMorningHour(7)
        XCTAssertEqual(viewModel.morningHour, 7)
        
        // Final state should be correct
        XCTAssertEqual(mockStore.settings.morningHour, 7)
    }
    
    func testUpdateStore_MultipleUpdates() {
        // Create different stores with different settings
        let store1 = Store()
        var settings1 = Settings()
        settings1.morningHour = 6
        store1.updateSettings(settings1)
        
        let store2 = Store()
        var settings2 = Settings()
        settings2.morningHour = 18
        store2.updateSettings(settings2)
        
        // Update viewModel with different stores
        viewModel.updateStore(store1)
        XCTAssertEqual(viewModel.morningHour, 6)
        
        viewModel.updateStore(store2)
        XCTAssertEqual(viewModel.morningHour, 18)
    }
}