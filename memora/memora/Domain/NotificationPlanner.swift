//
//  NotificationPlanner.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import UserNotifications

class NotificationPlanner {
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    func scheduleMorningReminder(at hour: Int, cardCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "復習の時間です"
        content.body = "今日の復習 \(cardCount)枚"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "morning-reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func reorganizeNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // TODO: Reschedule notifications based on current data
    }
}
