//
//  NotificationPlanner.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import UserNotifications

/// NotificationPlannerは通知機能を管理するクラスです
/// Requirements: 3.1, 3.2 - UNUserNotificationCenter権限要求機能、基本的な通知予約・削除機能
class NotificationPlanner: ObservableObject {
    
    private let center = UNUserNotificationCenter.current()
    private let morningReminderIdentifier = "morning-reminder"
    
    /// 通知権限を要求します
    /// - Returns: 権限が許可された場合はtrue、拒否された場合はfalse
    func requestAuthorization() async -> Bool {
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
    
    /// 現在の通知権限ステータスを取得します
    /// - Returns: 通知権限が許可されている場合はtrue
    func checkAuthorizationStatus() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    /// 朝の復習リマインダーを予約します
    /// - Parameters:
    ///   - hour: 通知時刻（0-23時）
    ///   - cardCount: 今日復習すべきカードの枚数
    func scheduleMorningReminder(at hour: Int, cardCount: Int) {
        // 時刻の妥当性チェック
        guard hour >= 0 && hour <= 23 else {
            print("Invalid hour: \(hour). Must be between 0 and 23.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "復習の時間です"
        content.body = "今日の復習 \(cardCount)枚"
        content.sound = .default
        content.badge = NSNumber(value: cardCount)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: morningReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule morning reminder: \(error)")
            } else {
                print("Successfully scheduled morning reminder at \(hour):00 for \(cardCount) cards")
            }
        }
    }
    
    /// 朝の復習リマインダーを削除します
    func cancelMorningReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [morningReminderIdentifier])
        print("Cancelled morning reminder")
    }
    
    /// 全ての通知予約を削除して再編成します
    /// 設定変更時やデータ更新時に呼び出されます
    func reorganizeNotifications() {
        center.removeAllPendingNotificationRequests()
        print("Removed all pending notifications for reorganization")
    }
    
    /// 現在予約されている通知の数を取得します（デバッグ用）
    func getPendingNotificationCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    /// 予約されている通知の詳細を取得します（デバッグ用）
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await center.pendingNotificationRequests()
    }
}
