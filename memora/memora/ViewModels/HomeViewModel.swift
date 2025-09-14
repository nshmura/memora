//
//  HomeViewModel.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var todayReviewCount: Int = 0
    @Published var consecutiveDays: Int = 0
    @Published var nextNotificationTime: String = ""
    
    private var store: Store
    
    init(store: Store = Store()) {
        self.store = store
        updateTodayReviewCount()
        updateConsecutiveDays()
        updateNextNotificationTime()
    }
    
    func updateStore(_ store: Store) {
        self.store = store
    }
    
    // MARK: - 今日の復習枚数計算
    
    private func updateTodayReviewCount() {
        let today = DateUtility.startOfDay(for: Date())
        
        let todayCards = store.cards.filter { card in
            // nextDueが今日以前のカードをカウント
            return card.nextDue <= today
        }
        
        todayReviewCount = todayCards.count
    }
    
    // MARK: - 連続学習日数計算
    
    private func updateConsecutiveDays() {
        guard !store.reviewLogs.isEmpty else {
            consecutiveDays = 0
            return
        }
        
        // レビューログを日付順（新しい順）にソート
        let sortedLogs = store.reviewLogs.sorted { $0.reviewedAt > $1.reviewedAt }
        
        guard let mostRecentLog = sortedLogs.first else {
            consecutiveDays = 0
            return
        }
        
        // 最新のログが今日または昨日でない場合は0
        let today = DateUtility.startOfDay(for: Date())
        let yesterday = DateUtility.addDays(to: today, days: -1)
        let mostRecentLogDate = DateUtility.startOfDay(for: mostRecentLog.reviewedAt)
        
        if mostRecentLogDate != today && mostRecentLogDate != yesterday {
            consecutiveDays = 0
            return
        }
        
        // 連続日数を計算
        var currentDate = today
        var count = 0
        
        // 今日の学習がある場合は1日としてカウント
        if hasReviewOnDate(currentDate, in: sortedLogs) {
            count = 1
            currentDate = DateUtility.addDays(to: currentDate, days: -1)
        } else if mostRecentLogDate == yesterday {
            // 今日は学習していないが昨日は学習している場合
            count = 1
            currentDate = DateUtility.addDays(to: currentDate, days: -2)
        }
        
        // 遡って連続日数を計算
        while hasReviewOnDate(currentDate, in: sortedLogs) {
            count += 1
            currentDate = DateUtility.addDays(to: currentDate, days: -1)
        }
        
        consecutiveDays = count
    }
    
    private func hasReviewOnDate(_ date: Date, in logs: [ReviewLog]) -> Bool {
        let targetDate = DateUtility.startOfDay(for: date)
        return logs.contains { log in
            DateUtility.startOfDay(for: log.reviewedAt) == targetDate
        }
    }
    
    // MARK: - 次回通知予定表示
    
    private func updateNextNotificationTime() {
        let settings = store.settings
        nextNotificationTime = formatNotificationTime(morningHour: settings.morningHour)
    }
    
    private func formatNotificationTime(morningHour: Int) -> String {
        return String(format: "%02d:00", morningHour)
    }
    
    // MARK: - Public Methods
    
    func refresh() {
        updateTodayReviewCount()
        updateConsecutiveDays()
        updateNextNotificationTime()
    }
}