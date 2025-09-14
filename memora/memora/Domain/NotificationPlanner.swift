//
//  NotificationPlanner.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import UserNotifications

/// NotificationPlannerは通知機能を管理するクラスです
/// Requirements: 3.1, 3.2, 3.3 - UNUserNotificationCenter権限要求機能、基本的な通知予約・削除機能、朝の復習通知
class NotificationPlanner: ObservableObject {
    
    private let center = UNUserNotificationCenter.current()
    private let morningReminderIdentifier = "morning-reminder"
    
    /// Store reference for accessing card data
    private weak var store: Store?
    
    /// Initialize with store reference for card count calculation
    init(store: Store? = nil) {
        self.store = store
    }
    
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
    
    /// 朝の復習リマインダーを予約します（設定時刻と自動カード枚数計算）
    /// - Parameter hour: 通知時刻（0-23時）
    func scheduleMorningReminder(at hour: Int) {
        Task {
            await scheduleMorningReminderInternal(at: hour)
        }
    }
    
    /// 朝の復習リマインダーを予約します
    /// - Parameters:
    ///   - hour: 通知時刻（0-23時）
    ///   - cardCount: 今日復習すべきカードの枚数
    func scheduleMorningReminder(at hour: Int, cardCount: Int) {
        Task {
            await scheduleMorningReminderInternal(at: hour, explicitCardCount: cardCount)
        }
    }
    
    /// 今日復習すべきカードの枚数を計算します
    /// - Returns: 今日復習すべきカードの枚数
    func calculateTodaysDueCardCount() -> Int {
        guard let store = store else {
            print("Store not available for card count calculation")
            return 0
        }
        
        let today = DateUtility.startOfDay(for: Date())
        let todayCards = store.cards.filter { card in
            return card.nextDue <= today
        }
        
        return todayCards.count
    }
    
    /// 朝の復習リマインダーを予約します（内部実装・テスト用）
    /// - Parameters:
    ///   - hour: 通知時刻（0-23時）
    ///   - explicitCardCount: 明示的に指定されたカード枚数（nilの場合は自動計算）
    func scheduleMorningReminderInternal(at hour: Int, explicitCardCount: Int? = nil) async {
        // 時刻の妥当性チェック
        guard hour >= 0 && hour <= 23 else {
            print("Invalid hour: \(hour). Must be between 0 and 23.")
            return
        }
        
        // 通知権限チェック
        guard await checkAuthorizationStatus() else {
            print("Notification authorization not granted. Cannot schedule morning reminder.")
            return
        }
        
        // カード枚数の計算
        let cardCount = explicitCardCount ?? calculateTodaysDueCardCount()
        
        let content = UNMutableNotificationContent()
        content.title = "復習の時間です"
        content.body = cardCount > 0 ? "今日の復習 \(cardCount)枚" : "今日の復習はありません"
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
        
        // 既存の朝の通知をキャンセル
        cancelMorningReminder()
        
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
        Task {
            await reorganizeNotificationsAsync()
        }
    }
    
    /// 通知の再編成（設定に基づいて朝の通知を再スケジュール）
    /// - Parameter morningHour: 新しい朝の通知時刻（設定から取得）
    func reorganizeNotifications(morningHour: Int) {
        Task {
            // 全ての通知をクリア
            center.removeAllPendingNotificationRequests()
            print("Removed all pending notifications for reorganization")
            
            // 朝の通知を再スケジュール
            await scheduleMorningReminderInternal(at: morningHour)
        }
    }
    
    /// 非同期で通知の再編成を実行
    private func reorganizeNotificationsAsync() async {
        center.removeAllPendingNotificationRequests()
        print("Removed all pending notifications for reorganization")
        
        // Storeから設定を取得して朝の通知を再スケジュール
        if let store = store {
            await scheduleMorningReminderInternal(at: store.settings.morningHour)
        }
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
