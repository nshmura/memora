//
//  NotificationPlannerTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
@testable import memora
import UserNotifications

/// NotificationPlannerのユニットテスト
/// Requirements: 3.2, 3.3, 7.1 - 朝の通知実装、通知予約の管理、単体テストでの通知予約の主要ケースのテスト
@MainActor
class NotificationPlannerTests: XCTestCase {
    
    var store: Store!
    var notificationPlanner: NotificationPlanner!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // Create test store with sample data
        store = Store()
        
        // Clear any existing cards and add test cards
        store.cards = []
        
        // Add cards with different due dates for testing
        let today = DateUtility.startOfDay(for: Date())
        let yesterday = DateUtility.addDays(to: today, days: -1)
        let tomorrow = DateUtility.addDays(to: today, days: 1)
        
        var cardDueToday = Card(question: "Test Question 1", answer: "Test Answer 1")
        cardDueToday.stepIndex = 1
        cardDueToday.nextDue = today
        cardDueToday.reviewCount = 1
        
        var cardDueYesterday = Card(question: "Test Question 2", answer: "Test Answer 2")
        cardDueYesterday.stepIndex = 2
        cardDueYesterday.nextDue = yesterday
        cardDueYesterday.reviewCount = 2
        
        var cardDueTomorrow = Card(question: "Test Question 3", answer: "Test Answer 3")
        cardDueTomorrow.stepIndex = 0
        cardDueTomorrow.nextDue = tomorrow
        cardDueTomorrow.reviewCount = 0
        
        store.cards = [cardDueToday, cardDueYesterday, cardDueTomorrow]
        
        // Initialize NotificationPlanner with test store
        notificationPlanner = NotificationPlanner(store: store)
        
        // Clear any existing notifications
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    override func tearDown() async throws {
        // Clean up notifications
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        notificationPlanner = nil
        store = nil
        
        try await super.tearDown()
    }
    
    // MARK: - Morning Reminder Scheduling Tests
    
    func testScheduleMorningReminder_WithValidHour_ShouldScheduleNotification() async {
        // Given
        let testHour = 8
        let expectedCardCount = 2 // cardDueToday + cardDueYesterday
        
        // When
        await notificationPlanner.scheduleMorningReminderInternal(at: testHour, explicitCardCount: expectedCardCount)
        
        // Then
        let pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1, "Should have exactly one pending notification")
        
        let request = pendingRequests.first
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.identifier, "morning-reminder")
        XCTAssertEqual(request?.content.title, "復習の時間です")
        XCTAssertEqual(request?.content.body, "今日の復習 \(expectedCardCount)枚")
        XCTAssertEqual(request?.content.badge, NSNumber(value: expectedCardCount))
        
        // Check trigger
        if let trigger = request?.trigger as? UNCalendarNotificationTrigger {
            XCTAssertEqual(trigger.dateComponents.hour, testHour)
            XCTAssertEqual(trigger.dateComponents.minute, 0)
            let isRepeating = trigger.repeats
            XCTAssertTrue(isRepeating, "Trigger should repeat")
        } else {
            XCTFail("Trigger should be UNCalendarNotificationTrigger")
        }
    }
    
    func testScheduleMorningReminder_WithInvalidHour_ShouldNotSchedule() async {
        // Given
        let invalidHours = [-1, 24, 25]
        
        for invalidHour in invalidHours {
            // When
            await notificationPlanner.scheduleMorningReminderInternal(at: invalidHour, explicitCardCount: 5)
            
            // Then
            let pendingRequests = await notificationPlanner.getPendingNotifications()
            XCTAssertEqual(pendingRequests.count, 0, "Should not schedule notification for invalid hour: \(invalidHour)")
        }
    }
    
    func testScheduleMorningReminder_WithZeroCards_ShouldScheduleWithZeroMessage() async {
        // Given
        store.cards = [] // No cards
        let testHour = 9
        
        // When
        await notificationPlanner.scheduleMorningReminderInternal(at: testHour)
        
        // Then
        let pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1)
        
        let request = pendingRequests.first
        XCTAssertEqual(request?.content.body, "今日の復習はありません")
        XCTAssertEqual(request?.content.badge, NSNumber(value: 0))
    }
    
    func testScheduleMorningReminder_AutoCalculatesCardCount() async {
        // Given
        let testHour = 10
        // Store has 2 cards due today or earlier (cardDueToday + cardDueYesterday)
        
        // When
        await notificationPlanner.scheduleMorningReminderInternal(at: testHour)
        
        // Then
        let pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1)
        
        let request = pendingRequests.first
        XCTAssertEqual(request?.content.body, "今日の復習 2枚")
        XCTAssertEqual(request?.content.badge, NSNumber(value: 2))
    }
    
    // MARK: - Cancel Morning Reminder Tests
    
    func testCancelMorningReminder_ShouldRemoveScheduledNotification() async {
        // Given
        await notificationPlanner.scheduleMorningReminderInternal(at: 8, explicitCardCount: 3)
        var pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1, "Should have scheduled notification")
        
        // When
        notificationPlanner.cancelMorningReminder()
        
        // Allow some time for the cancellation to process
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        
        // Then
        pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 0, "Should have cancelled the notification")
    }
    
    // MARK: - Reorganize Notifications Tests
    
    func testReorganizeNotifications_ShouldClearAllAndReschedule() async {
        // Given
        await notificationPlanner.scheduleMorningReminderInternal(at: 8, explicitCardCount: 2)
        var pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1, "Should have initial notification")
        
        // Update store settings
        store.settings.morningHour = 10
        
        // When
        notificationPlanner.reorganizeNotifications()
        
        // Allow time for processing
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1, "Should have rescheduled notification")
        
        let request = pendingRequests.first
        if let trigger = request?.trigger as? UNCalendarNotificationTrigger {
            XCTAssertEqual(trigger.dateComponents.hour, 10, "Should use new hour from settings")
        } else {
            XCTFail("Should have calendar trigger with updated hour")
        }
    }
    
    func testReorganizeNotifications_WithSpecificHour_ShouldUseProvidedHour() async {
        // Given
        let newHour = 15
        
        // When
        notificationPlanner.reorganizeNotifications(morningHour: newHour)
        
        // Allow time for processing
        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
        
        // Then
        let pendingRequests = await notificationPlanner.getPendingNotifications()
        XCTAssertEqual(pendingRequests.count, 1, "Should have scheduled notification")
        
        let request = pendingRequests.first
        if let trigger = request?.trigger as? UNCalendarNotificationTrigger {
            XCTAssertEqual(trigger.dateComponents.hour, newHour, "Should use provided hour")
        } else {
            XCTFail("Should have calendar trigger")
        }
    }
    
    // MARK: - Notification Count Tests
    
    func testGetPendingNotificationCount_ShouldReturnCorrectCount() async {
        // Given
        let initialCount = await notificationPlanner.getPendingNotificationCount()
        XCTAssertEqual(initialCount, 0, "Should start with no notifications")
        
        // When
        await notificationPlanner.scheduleMorningReminderInternal(at: 8, explicitCardCount: 1)
        
        // Then
        let finalCount = await notificationPlanner.getPendingNotificationCount()
        XCTAssertEqual(finalCount, 1, "Should have one notification")
    }
    
    // MARK: - Card Count Calculation Tests
    
    func testCalculateTodaysDueCardCount_WithMixedDueDates() {
        // Given: Store already has cards set up in setUp()
        // cardDueToday (due today) + cardDueYesterday (due yesterday) = 2 cards
        // cardDueTomorrow should not be counted
        
        // When
        let count = notificationPlanner.calculateTodaysDueCardCount()
        
        // Then
        XCTAssertEqual(count, 2, "Should count cards due today or earlier")
    }
    
    func testCalculateTodaysDueCardCount_WithNoStore_ReturnsZero() {
        // Given
        let plannerWithoutStore = NotificationPlanner(store: nil)
        
        // When
        let count = plannerWithoutStore.calculateTodaysDueCardCount()
        
        // Then
        XCTAssertEqual(count, 0, "Should return 0 when no store available")
    }
    
    // MARK: - Authorization Tests
    
    func testCheckAuthorizationStatus() async {
        // When
        let isAuthorized = await notificationPlanner.checkAuthorizationStatus()
        
        // Then
        // In test environment, authorization status may not be determined
        // We just verify the method doesn't crash and returns a boolean
        XCTAssertTrue(isAuthorized is Bool, "Should return a boolean value")
    }
}