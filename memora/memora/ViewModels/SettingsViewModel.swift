//
//  SettingsViewModel.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import UserNotifications

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var morningHour: Int = 8
    @Published var intervals: [Int] = [0, 1, 2, 4, 7, 15, 30]
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    private var store: Store
    
    init(store: Store = Store()) {
        self.store = store
        loadSettings()
        checkNotificationPermission()
    }
    
    func updateStore(_ store: Store) {
        self.store = store
        loadSettings()
    }
    
    // MARK: - Settings Loading
    
    private func loadSettings() {
        morningHour = store.settings.morningHour
        intervals = store.settings.intervals
    }
    
    // MARK: - Morning Hour Management
    
    func updateMorningHour(_ newHour: Int) {
        guard newHour >= 0 && newHour <= 23 else {
            return
        }
        
        morningHour = newHour
        
        // Update store settings
        var updatedSettings = store.settings
        updatedSettings.morningHour = newHour
        store.updateSettings(updatedSettings)
        
        // Reorganize notifications with new time
        Task {
            await reorganizeNotifications()
        }
    }
    
    // MARK: - Notification Permission Management
    
    private func checkNotificationPermission() {
        Task {
            let current = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                self.notificationPermissionStatus = current.authorizationStatus
            }
        }
    }
    
    func checkNotificationPermissions() async {
        let current = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            self.notificationPermissionStatus = current.authorizationStatus
        }
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.notificationPermissionStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await reorganizeNotifications()
            }
            
            return granted
        } catch {
            await MainActor.run {
                self.notificationPermissionStatus = .denied
            }
            return false
        }
    }
    
    // MARK: - Notification Reorganization
    
    private func reorganizeNotifications() async {
        // Cancel all existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Only schedule new notifications if permission is granted
        guard notificationPermissionStatus == .authorized else {
            return
        }
        
        // Schedule morning reminder for tomorrow and several days ahead
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.timeZone = TimeZone(identifier: "Asia/Tokyo")
        dateComponents.hour = morningHour
        dateComponents.minute = 0
        
        // Schedule notifications for the next 7 days
        for dayOffset in 1...7 {
            let futureDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            let startOfDay = DateUtility.startOfDay(for: futureDate)
            
            // Count due cards for that day
            let dueCardsCount = countDueCards(for: startOfDay)
            
            if dueCardsCount > 0 {
                let content = UNMutableNotificationContent()
                content.title = "今日の復習"
                content.body = "復習するカードが\(dueCardsCount)枚あります"
                content.sound = .default
                
                // Set the notification date
                let notificationDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
                var notificationComponents = Calendar.current.dateComponents([.year, .month, .day], from: notificationDate)
                notificationComponents.hour = morningHour
                notificationComponents.minute = 0
                notificationComponents.timeZone = TimeZone(identifier: "Asia/Tokyo")
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: notificationComponents, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "morning-reminder-\(dayOffset)",
                    content: content,
                    trigger: trigger
                )
                
                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    // Handle notification scheduling error silently
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
    
    private func countDueCards(for date: Date) -> Int {
        let targetDate = DateUtility.startOfDay(for: date)
        return store.cards.filter { card in
            DateUtility.startOfDay(for: card.nextDue) <= targetDate
        }.count
    }
    
    // MARK: - Helper Properties
    
    var morningTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        var morningComponents = components
        morningComponents.hour = morningHour
        morningComponents.minute = 0
        
        if let morningTime = calendar.date(from: morningComponents) {
            return formatter.string(from: morningTime)
        }
        
        return "\(morningHour):00"
    }
    
    var notificationStatusString: String {
        switch notificationPermissionStatus {
        case .notDetermined:
            return "未設定"
        case .denied:
            return "拒否"
        case .authorized:
            return "許可"
        case .provisional:
            return "仮許可"
        case .ephemeral:
            return "一時許可"
        @unknown default:
            return "不明"
        }
    }
    
    var canReceiveNotifications: Bool {
        return notificationPermissionStatus == .authorized
    }
}