import XCTest
@testable import memora

@MainActor
class StudyViewModelTests: XCTestCase {
    
    var studyViewModel: StudyViewModel!
    var mockStore: Store!
    
    override func setUp() {
        super.setUp()
        mockStore = Store()
        studyViewModel = StudyViewModel(store: mockStore)
    }
    
    override func tearDown() {
        studyViewModel = nil
        mockStore = nil
        super.tearDown()
    }
    
    // MARK: - 今日復習すべきカード取得ロジックのテスト
    
    func testLoadTodaysDueCards_WithNoDueCards() {
        // Given: No cards are due
        let tomorrow = DateUtility.addDays(to: Date(), days: 1)
        let futureCard = Card(question: "Future", answer: "Card", tags: [])
        var updatedCard = futureCard
        updatedCard.nextDue = tomorrow
        mockStore.cards = [updatedCard]
        
        // When: Loading today's due cards
        studyViewModel.loadTodaysDueCards()
        
        // Then: No cards should be due
        XCTAssertEqual(studyViewModel.dueCards.count, 0)
        XCTAssertEqual(studyViewModel.totalCount, 0)
        XCTAssertNil(studyViewModel.currentCard)
        XCTAssertFalse(studyViewModel.isStudyCompleted)
    }
    
    func testLoadTodaysDueCards_WithDueCards() {
        // Given: Cards are due today
        let today = DateUtility.startOfDay(for: Date())
        let yesterday = DateUtility.addDays(to: today, days: -1)
        
        let card1 = Card(question: "Q1", answer: "A1", tags: [])
        var dueCard1 = card1
        dueCard1.nextDue = today
        
        let card2 = Card(question: "Q2", answer: "A2", tags: [])
        var dueCard2 = card2
        dueCard2.nextDue = yesterday
        
        mockStore.cards = [dueCard1, dueCard2]
        
        // When: Loading today's due cards
        studyViewModel.loadTodaysDueCards()
        
        // Then: Both cards should be due
        XCTAssertEqual(studyViewModel.dueCards.count, 2)
        XCTAssertEqual(studyViewModel.totalCount, 2)
        XCTAssertNotNil(studyViewModel.currentCard)
        XCTAssertEqual(studyViewModel.currentCard?.question, "Q1")
        XCTAssertEqual(studyViewModel.currentIndex, 0)
        XCTAssertFalse(studyViewModel.isStudyCompleted)
        XCTAssertFalse(studyViewModel.showingAnswer)
    }
    
    func testHasCardsToStudy() {
        // Given: No due cards
        studyViewModel.dueCards = []
        XCTAssertFalse(studyViewModel.hasCardsToStudy)
        
        // Given: Due cards exist
        let card = Card(question: "Q", answer: "A", tags: [])
        studyViewModel.dueCards = [card]
        XCTAssertTrue(studyViewModel.hasCardsToStudy)
    }
    
    // MARK: - 学習進捗管理のテスト
    
    func testShowAnswer() {
        // Given: Initial state
        XCTAssertFalse(studyViewModel.showingAnswer)
        
        // When: Showing answer
        studyViewModel.showAnswer()
        
        // Then: Answer should be visible
        XCTAssertTrue(studyViewModel.showingAnswer)
    }
    
    func testProgressCalculation() {
        // Given: 3 cards, at index 0
        studyViewModel.totalCount = 3
        studyViewModel.currentIndex = 0
        XCTAssertEqual(studyViewModel.progress, 0.0, accuracy: 0.01)
        XCTAssertEqual(studyViewModel.progressText, "1 / 3")
        XCTAssertEqual(studyViewModel.remainingCount, 2)
        
        // Given: At index 1
        studyViewModel.currentIndex = 1
        XCTAssertEqual(studyViewModel.progress, 0.33, accuracy: 0.01)
        XCTAssertEqual(studyViewModel.progressText, "2 / 3")
        XCTAssertEqual(studyViewModel.remainingCount, 1)
        
        // Given: At last index
        studyViewModel.currentIndex = 2
        XCTAssertEqual(studyViewModel.progress, 0.67, accuracy: 0.01)
        XCTAssertEqual(studyViewModel.progressText, "3 / 3")
        XCTAssertEqual(studyViewModel.remainingCount, 0)
    }
    
    func testProgressWithNoCards() {
        // Given: No cards
        studyViewModel.totalCount = 0
        studyViewModel.currentIndex = 0
        
        // Then: Progress should be 0
        XCTAssertEqual(studyViewModel.progress, 0.0)
        XCTAssertEqual(studyViewModel.progressText, "1 / 0")
        XCTAssertEqual(studyViewModel.remainingCount, 0)
    }
    
    func testMoveToNextCard() {
        // Given: Multiple cards setup
        let card1 = Card(question: "Q1", answer: "A1", tags: [])
        let card2 = Card(question: "Q2", answer: "A2", tags: [])
        studyViewModel.dueCards = [card1, card2]
        studyViewModel.totalCount = 2
        studyViewModel.currentIndex = 0
        studyViewModel.currentCard = card1
        studyViewModel.showingAnswer = true
        
        // When: Moving to next card
        studyViewModel.moveToNextCard()
        
        // Then: Should be on second card
        XCTAssertEqual(studyViewModel.currentIndex, 1)
        XCTAssertEqual(studyViewModel.currentCard?.question, "Q2")
        XCTAssertFalse(studyViewModel.showingAnswer)
        XCTAssertFalse(studyViewModel.isStudyCompleted)
    }
    
    func testMoveToNextCard_LastCard() {
        // Given: On last card
        let card = Card(question: "Q", answer: "A", tags: [])
        studyViewModel.dueCards = [card]
        studyViewModel.totalCount = 1
        studyViewModel.currentIndex = 0
        studyViewModel.currentCard = card
        studyViewModel.showingAnswer = true
        
        // When: Moving past last card
        studyViewModel.moveToNextCard()
        
        // Then: Study should be completed
        XCTAssertEqual(studyViewModel.currentIndex, 1)
        XCTAssertNil(studyViewModel.currentCard)
        XCTAssertFalse(studyViewModel.showingAnswer)
        XCTAssertTrue(studyViewModel.isStudyCompleted)
    }
    
    // MARK: - 正誤判定とScheduler連携ロジックのテスト
    
    func testAnswerCard_Correct() {
        // Given: A card at step 0
        let card = Card(question: "Test", answer: "Answer", tags: [])
        mockStore.cards = [card]
        studyViewModel.currentCard = card
        studyViewModel.dueCards = [card]
        studyViewModel.totalCount = 1
        studyViewModel.currentIndex = 0
        
        let initialReviewLogCount = mockStore.reviewLogs.count
        
        // When: Answering correctly
        studyViewModel.answerCard(isCorrect: true)
        
        // Then: Card should advance step and be removed from due cards
        let updatedCard = mockStore.cards.first { $0.id == card.id }
        XCTAssertNotNil(updatedCard)
        XCTAssertEqual(updatedCard?.stepIndex, 1) // Advanced from 0 to 1
        XCTAssertTrue(updatedCard?.lastResult == true)
        XCTAssertEqual(updatedCard?.reviewCount, card.reviewCount + 1)
        
        // Review log should be created
        XCTAssertEqual(mockStore.reviewLogs.count, initialReviewLogCount + 1)
        let reviewLog = mockStore.reviewLogs.last
        XCTAssertNotNil(reviewLog)
        XCTAssertEqual(reviewLog?.cardId, card.id)
        XCTAssertEqual(reviewLog?.result, true)
        XCTAssertEqual(reviewLog?.previousStep, 0)
        XCTAssertEqual(reviewLog?.nextStep, 1)
        
        // Study should be completed (no more cards)
        XCTAssertTrue(studyViewModel.isStudyCompleted)
        XCTAssertNil(studyViewModel.currentCard)
    }
    
    func testAnswerCard_Incorrect() {
        // Given: A card at step 2
        var card = Card(question: "Test", answer: "Answer", tags: [])
        card.stepIndex = 2
        mockStore.cards = [card]
        studyViewModel.currentCard = card
        studyViewModel.dueCards = [card]
        studyViewModel.totalCount = 1
        studyViewModel.currentIndex = 0
        
        let initialReviewLogCount = mockStore.reviewLogs.count
        
        // When: Answering incorrectly
        studyViewModel.answerCard(isCorrect: false)
        
        // Then: Card should reset to step 0
        let updatedCard = mockStore.cards.first { $0.id == card.id }
        XCTAssertNotNil(updatedCard)
        XCTAssertEqual(updatedCard?.stepIndex, 0) // Reset to 0
        XCTAssertTrue(updatedCard?.lastResult == false)
        XCTAssertEqual(updatedCard?.reviewCount, card.reviewCount + 1)
        
        // Review log should be created
        XCTAssertEqual(mockStore.reviewLogs.count, initialReviewLogCount + 1)
        let reviewLog = mockStore.reviewLogs.last
        XCTAssertNotNil(reviewLog)
        XCTAssertEqual(reviewLog?.cardId, card.id)
        XCTAssertEqual(reviewLog?.result, false)
        XCTAssertEqual(reviewLog?.previousStep, 2)
        XCTAssertEqual(reviewLog?.nextStep, 0)
        
        // Study should be completed (no more cards)
        XCTAssertTrue(studyViewModel.isStudyCompleted)
        XCTAssertNil(studyViewModel.currentCard)
    }
    
    func testAnswerCard_WithMultipleCards() {
        // Given: Multiple cards
        let card1 = Card(question: "Q1", answer: "A1", tags: [])
        let card2 = Card(question: "Q2", answer: "A2", tags: [])
        mockStore.cards = [card1, card2]
        studyViewModel.currentCard = card1
        studyViewModel.dueCards = [card1, card2]
        studyViewModel.totalCount = 2
        studyViewModel.currentIndex = 0
        
        // When: Answering first card correctly
        studyViewModel.answerCard(isCorrect: true)
        
        // Then: Should move to second card
        XCTAssertFalse(studyViewModel.isStudyCompleted)
        XCTAssertEqual(studyViewModel.currentCard?.question, "Q2")
        XCTAssertEqual(studyViewModel.dueCards.count, 1) // First card removed
        XCTAssertEqual(studyViewModel.totalCount, 1)
    }
    
    // MARK: - Study Session Management のテスト
    
    func testStudyCompletionMessage() {
        // Given: No cards to study
        studyViewModel.totalCount = 0
        XCTAssertEqual(studyViewModel.studyCompletionMessage, "今日の復習はありません")
        
        // Given: Cards were studied
        studyViewModel.totalCount = 3
        XCTAssertEqual(studyViewModel.studyCompletionMessage, "お疲れ様でした！\n今日の復習を完了しました")
    }
    
    func testStartNewStudySession() {
        // Given: Some initial state
        studyViewModel.studyStartTime = Date(timeIntervalSinceNow: -100)
        let oldStartTime = studyViewModel.studyStartTime
        
        // When: Starting new session
        studyViewModel.startNewStudySession()
        
        // Then: Start time should be updated
        XCTAssertGreaterThan(studyViewModel.studyStartTime, oldStartTime)
    }
    
    func testResetStudy() {
        // Given: Study in progress
        studyViewModel.currentIndex = 2
        studyViewModel.showingAnswer = true
        studyViewModel.isStudyCompleted = true
        
        // When: Resetting study
        studyViewModel.resetStudy()
        
        // Then: Should return to initial state
        XCTAssertEqual(studyViewModel.currentIndex, 0)
        XCTAssertFalse(studyViewModel.showingAnswer)
        XCTAssertFalse(studyViewModel.isStudyCompleted)
    }
    
    // MARK: - Edge Cases のテスト
    
    func testAnswerCard_WithNoCurrentCard() {
        // Given: No current card
        studyViewModel.currentCard = nil
        let initialCardCount = mockStore.cards.count
        let initialLogCount = mockStore.reviewLogs.count
        
        // When: Trying to answer
        studyViewModel.answerCard(isCorrect: true)
        
        // Then: Nothing should change
        XCTAssertEqual(mockStore.cards.count, initialCardCount)
        XCTAssertEqual(mockStore.reviewLogs.count, initialLogCount)
    }
    
    func testUpdateStore() {
        // Given: New store with different cards
        let newStore = Store()
        let newCard = Card(question: "New", answer: "Card", tags: [])
        var dueNewCard = newCard
        dueNewCard.nextDue = DateUtility.startOfDay(for: Date())
        newStore.cards = [dueNewCard]
        
        // When: Updating store
        studyViewModel.updateStore(newStore)
        
        // Then: Should load new cards
        XCTAssertEqual(studyViewModel.dueCards.count, 1)
        XCTAssertEqual(studyViewModel.currentCard?.question, "New")
    }
}