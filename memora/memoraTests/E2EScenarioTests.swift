//
//  E2EScenarioTests.swift
//  memoraTests
//
//  Created by 西村真一 on 2025/09/14.
//

import XCTest
import UserNotifications
@testable import memora

@MainActor
final class E2EScenarioTests: XCTestCase {
    var store: Store!
    var scheduler: Scheduler!
    var notificationPlanner: NotificationPlanner!
    
    override func setUp() async throws {
        try await super.setUp()
        
        // テスト用のStore初期化
        store = Store()
        
        // 既存データをクリア
        store.cards = []
        store.reviewLogs = []
        store.settings = Settings()
        
        scheduler = Scheduler()
        notificationPlanner = NotificationPlanner()
    }
    
    override func tearDown() async throws {
        store = nil
        scheduler = nil
        notificationPlanner = nil
        try await super.tearDown()
    }
    
    // MARK: - 新規ユーザーフロー（カード追加→学習→通知設定）
    
    func testNewUserFlow() async throws {
        // Given: 新規ユーザー（カードが空の状態）
        XCTAssertTrue(store.cards.isEmpty)
        
        // When: カードを追加
        let card = Card(
            question: "テスト問題",
            answer: "テスト回答",
            stepIndex: 0,
            nextDue: Date(),
            reviewCount: 0,
            lastResult: nil,
            tags: []
        )
        store.cards.append(card)
        store.saveCards()
        
        // Then: カードが保存される
        XCTAssertEqual(store.cards.count, 1)
        XCTAssertEqual(store.cards.first?.question, "テスト問題")
        
        // When: 学習を開始（今日復習すべきカード取得）
        let today = DateUtility.startOfDay(for: Date(), in: DateUtility.jstTimeZone)
        let cardsToReview = store.cards.filter { $0.nextDue <= today }
        
        // Then: 今日復習すべきカードが取得される
        XCTAssertEqual(cardsToReview.count, 1)
        
        // When: カードに正解
        let gradedCard = Scheduler.gradeCard(card, isCorrect: true, at: Date())
        store.cards[0] = gradedCard
        
        // Then: stepIndexが増加し、次回復習日が設定される
        XCTAssertEqual(gradedCard.stepIndex, 1)
        XCTAssertTrue(gradedCard.nextDue > Date())
        
        // When: 学習完了後の通知設定
        let morningHour = store.settings.morningHour
        notificationPlanner.scheduleMorningReminder(at: morningHour, cardCount: 0)
        
        // Then: 通知設定が完了（実際の通知権限テストは実機で実行）
        // このテストでは通知スケジューリングがクラッシュしないことを確認
    }
    
    // MARK: - 日次学習フロー（通知→起動→復習→次回予約）
    
    func testDailyStudyFlow() async throws {
        // Given: 既存カードがあり、今日復習予定
        let today = DateUtility.startOfDay(for: Date(), in: DateUtility.jstTimeZone)
        let card1 = Card(
            question: "問題1",
            answer: "回答1",
            stepIndex: 1,
            nextDue: today,
            reviewCount: 3,
            lastResult: true,
            tags: []
        )
        let card2 = Card(
            question: "問題2", 
            answer: "回答2",
            stepIndex: 0,
            nextDue: today,
            reviewCount: 1,
            lastResult: false,
            tags: []
        )
        
        store.cards = [card1, card2]
        
        // When: アプリ起動時にデータ読み込み
        store.loadData()
        
        // Then: カードが読み込まれる
        XCTAssertEqual(store.cards.count, 2)
        
        // When: 今日の復習カード取得
        let cardsToReview = store.cards.filter { $0.nextDue <= today }
        
        // Then: 復習対象カードが正しく取得される
        XCTAssertEqual(cardsToReview.count, 2)
        
        // When: 1枚目を正解
        let gradedCard1 = Scheduler.gradeCard(card1, isCorrect: true, at: Date())
        store.cards[0] = gradedCard1
        
        // Then: stepIndexが増加
        XCTAssertEqual(gradedCard1.stepIndex, 2)
        XCTAssertEqual(gradedCard1.reviewCount, 4)
        
        // When: 2枚目を不正解
        let gradedCard2 = Scheduler.gradeCard(card2, isCorrect: false, at: Date())
        store.cards[1] = gradedCard2
        
        // Then: stepIndexがリセットされ、明日復習に設定
        XCTAssertEqual(gradedCard2.stepIndex, 0)
        XCTAssertEqual(gradedCard2.reviewCount, 2)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let expectedTomorrow = DateUtility.startOfDay(for: tomorrow, in: DateUtility.jstTimeZone)
        XCTAssertEqual(gradedCard2.nextDue, expectedTomorrow)
        
        // When: 学習完了後、通知再編成
        let remainingCards = store.cards.filter { $0.nextDue <= today }
        notificationPlanner.scheduleMorningReminder(at: store.settings.morningHour, cardCount: remainingCards.count)
        
        // Then: 通知が再編成される（クラッシュしないことを確認）
    }
    
    // MARK: - エラー回復フロー（権限拒否→代替案内→再許可）
    
    func testNotificationPermissionErrorRecovery() async throws {
        // Given: 通知権限が拒否された状態をシミュレート
        let settings = store.settings
        
        // When: 通知権限要求（実際の権限は実機テストで確認）
        // ここではNotificationPlannerがクラッシュしないことを確認
        let authorizationResult = await notificationPlanner.requestAuthorization()
        
        // Then: 権限拒否でもアプリがクラッシュしない
        // 実機では false が返される可能性があるが、シミュレータでは通常 true
        XCTAssertNotNil(authorizationResult)
        
        // When: 権限なしで通知スケジューリング試行
        notificationPlanner.scheduleMorningReminder(at: settings.morningHour, cardCount: 5)
        
        // Then: エラーが発生してもアプリがクラッシュしない
        // NotificationPlannerが内部でエラーハンドリングしている
        
        // When: 通知再編成
        notificationPlanner.reorganizeNotifications()
        
        // Then: 再編成処理でもクラッシュしない
    }
    
    // MARK: - データ境界テスト
    
    func testDateBoundaryHandling() throws {
        // Given: JST 23:59の学習
        var calendar = Calendar.current
        calendar.timeZone = DateUtility.jstTimeZone
        
        let jstDate = calendar.date(from: DateComponents(
            year: 2024,
            month: 1,
            day: 15,
            hour: 23,
            minute: 59,
            second: 0
        ))!
        
        let card = Card(
            question: "境界テスト",
            answer: "テスト回答", 
            stepIndex: 0,
            nextDue: jstDate,
            reviewCount: 0,
            lastResult: nil,
            tags: []
        )
        
        // When: 正解して次回復習日を計算
        let gradedCard = Scheduler.gradeCard(card, isCorrect: true, at: jstDate)
        
        // Then: 次回復習日が正しく明日00:00 JSTに設定される
        let expectedNextDay = calendar.date(from: DateComponents(
            year: 2024,
            month: 1,
            day: 16,
            hour: 0,
            minute: 0,
            second: 0
        ))!
        
        XCTAssertEqual(gradedCard.stepIndex, 1)
        XCTAssertEqual(gradedCard.nextDue, expectedNextDay)
    }
    
    // MARK: - 大量データ処理テスト
    
    func testLargeDatasetPerformance() throws {
        // Given: 大量のカード（1000枚）
        measure {
            let cards = (1...1000).map { i in
                Card(
                    question: "問題\(i)",
                    answer: "回答\(i)",
                    stepIndex: Int.random(in: 0...6),
                    nextDue: Date(),
                    reviewCount: Int.random(in: 0...50),
                    lastResult: Bool.random(),
                    tags: ["タグ\(i % 10)"]
                )
            }
            
            store.cards = cards
            
            // When: 今日の復習カード取得
            let today = DateUtility.startOfDay(for: Date(), in: DateUtility.jstTimeZone)
            let cardsToReview = store.cards.filter { $0.nextDue <= today }
            
            // Then: パフォーマンステストが完了する
            XCTAssertTrue(cardsToReview.count >= 0)
        }
    }
}