//
//  StudyViewModel.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

@MainActor
class StudyViewModel: ObservableObject {
    @Published var currentCard: Card?
    @Published var dueCards: [Card] = []
    @Published var currentIndex: Int = 0
    @Published var totalCount: Int = 0
    @Published var showingAnswer: Bool = false
    @Published var isStudyCompleted: Bool = false
    @Published var studyStartTime: Date = Date()
    
    private var store: Store
    
    init(store: Store = Store()) {
        self.store = store
        loadTodaysDueCards()
    }
    
    func updateStore(_ store: Store) {
        self.store = store
        loadTodaysDueCards()
    }
    
    // MARK: - 今日復習すべきカード取得ロジック
    
    func loadTodaysDueCards() {
        let today = DateUtility.startOfDay(for: Date())
        
        // Filter cards that are due today or earlier
        dueCards = store.cards.filter { card in
            return card.nextDue <= today
        }
        
        totalCount = dueCards.count
        currentIndex = 0
        isStudyCompleted = false
        showingAnswer = false
        
        // Set current card
        if !dueCards.isEmpty {
            currentCard = dueCards[0]
            studyStartTime = Date()
        } else {
            currentCard = nil
        }
    }
    
    // MARK: - 学習進捗管理
    
    func showAnswer() {
        showingAnswer = true
    }
    
    func moveToNextCard() {
        showingAnswer = false
        currentIndex += 1
        
        if currentIndex >= dueCards.count {
            // Study completed
            isStudyCompleted = true
            currentCard = nil
        } else {
            // Move to next card
            currentCard = dueCards[currentIndex]
        }
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(currentIndex) / Double(totalCount)
    }
    
    var progressText: String {
        return "\(currentIndex + 1) / \(totalCount)"
    }
    
    var remainingCount: Int {
        return max(0, totalCount - currentIndex - 1)
    }
    
    // MARK: - 正誤判定とScheduler連携ロジック
    
    func answerCard(isCorrect: Bool) {
        guard let card = currentCard else { return }
        
        let reviewStartTime = studyStartTime
        let latencyMs = Int(Date().timeIntervalSince(reviewStartTime) * 1000)
        
        // Grade the card using Scheduler
        let gradedCard = Scheduler.gradeCard(card, isCorrect: isCorrect)
        
        // Update the card in store
        if let index = store.cards.firstIndex(where: { $0.id == card.id }) {
            store.cards[index] = gradedCard
        }
        
        // Create review log
        let reviewLog = ReviewLog(
            cardId: card.id,
            previousStep: card.stepIndex,
            nextStep: gradedCard.stepIndex,
            result: isCorrect,
            latencyMs: latencyMs
        )
        
        store.reviewLogs.append(reviewLog)
        
        // Save data
        store.saveCards()
        store.saveReviewLogs()
        
        // Update current card with graded version
        currentCard = gradedCard
        
        // Update due cards list to remove this card
        if let dueIndex = dueCards.firstIndex(where: { $0.id == card.id }) {
            dueCards.remove(at: dueIndex)
            totalCount = dueCards.count
            
            // Adjust current index if necessary
            if currentIndex >= dueCards.count {
                currentIndex = max(0, dueCards.count - 1)
            }
        }
        
        // Move to next card or complete study
        moveToNextCard()
    }
    
    // MARK: - Study Session Management
    
    func startNewStudySession() {
        studyStartTime = Date()
        loadTodaysDueCards()
    }
    
    func resetStudy() {
        loadTodaysDueCards()
    }
    
    var hasCardsToStudy: Bool {
        return !dueCards.isEmpty
    }
    
    var studyCompletionMessage: String {
        if totalCount == 0 {
            return "今日の復習はありません"
        } else {
            return "お疲れ様でした！\n今日の復習を完了しました"
        }
    }
}