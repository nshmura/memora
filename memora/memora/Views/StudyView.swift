//
//  StudyView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: Store
    @StateObject private var viewModel = StudyViewModel()
    @State private var showingAnswer = false
    @State private var cardOffset: CGFloat = 0
    @State private var showingCompletion = false
    @State private var userAnswer = ""
    @State private var submittedAnswer = false
    @State private var isAnswerCorrect = false
    
    let retryMode: Bool
    
    init(retryMode: Bool = false) {
        self.retryMode = retryMode
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.hasCardsToStudy {
                studyContent
            } else {
                emptyState
            }
        }
        .navigationTitle(retryMode ? "復習やり直し" : "Study")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.updateStore(store)
            if retryMode {
                viewModel.loadTodayCompletedCards()
            }
        }
        .alert("学習完了！", isPresented: $showingCompletion) {
            Button("OK") {
                // 学習完了時は単純にアラートを閉じるだけ
            }
        } message: {
            Text("今日の復習が完了しました。お疲れ様でした！")
        }
    }
    
    private var studyContent: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressView
            
            // Card content
            cardView
                .offset(x: cardOffset)
                .animation(.easeInOut(duration: 0.3), value: cardOffset)
            
            Spacer()
            
            // Action buttons
            actionButtons
                .padding(.bottom, 20)
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(viewModel.currentIndex + 1) / \(viewModel.totalCount)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
    
    private var cardView: some View {
        VStack(spacing: 20) {
            if let currentCard = viewModel.currentCard {
                // Question
                VStack(alignment: .leading, spacing: 12) {
                    Text("問題:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(currentCard.question)
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Answer input field (only show if not submitted and not showing "don't know")
                if !submittedAnswer && !showingAnswer {
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            if userAnswer.isEmpty {
                                Text("答えを入力する")
                                    .foregroundColor(.secondary)
                                    .font(.title3)
                                    .padding(.leading, 4)
                            }
                            
                            TextEditor(text: $userAnswer)
                                .font(.title3)
                                .frame(minHeight: 45)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        HStack(spacing: 12) {
                            // Submit Answer button
                            Button(action: {
                                submitAnswer()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.forward.circle")
                                    Text("回答する")
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(userAnswer.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(12)
                            }
                            .disabled(userAnswer.isEmpty)
                            
                            // Don't Know button - smaller and less prominent
                            Button(action: {
                                showDontKnow()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.caption)
                                    Text("分からない")
                                        .font(.caption)
                                }
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Show answer after submission or "don't know"
                if submittedAnswer || showingAnswer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("正解:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(currentCard.answer)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .scale))
                    
                    // Show result feedback only for submitted answers (not for "don't know")
                    if submittedAnswer {
                        VStack(spacing: 8) {
                            if isAnswerCorrect {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    Text("✅ 正解")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                }
                            } else {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                    Text("❌ 不正解")
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .padding()
                        .background(isAnswerCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if submittedAnswer || showingAnswer {
                HStack(spacing: 12) {
                    // Next Card button - always show when answer is revealed
                    Button(action: {
                        nextCard()
                    }) {
                        HStack {
                            Text("次のカード")
                            Image(systemName: "arrow.right.circle")
                        }
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Text("答えを入力して回答してください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: retryMode ? "clock.arrow.circlepath" : "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(retryMode ? .orange : .green)
            
            Text(retryMode ? "今日やり直す復習はありません" : "今日の復習は完了しました！")
                .font(.title2)
                .fontWeight(.medium)
            
            Text(retryMode ? "まずは通常の学習を完了してください。" : "お疲れ様でした。明日も頑張りましょう。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    private func submitAnswer() {
        guard !userAnswer.isEmpty, let currentCard = viewModel.currentCard else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            submittedAnswer = true
            showingAnswer = true
            
            // Simple string comparison (case-insensitive, trimmed)
            let userAnswerCleaned = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let correctAnswerCleaned = currentCard.answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            isAnswerCorrect = userAnswerCleaned == correctAnswerCleaned
            
            viewModel.showAnswer()
        }
    }
    
    private func showDontKnow() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingAnswer = true
            submittedAnswer = false // Don't show correct/incorrect for "don't know"
            viewModel.showAnswer()
        }
    }
    
    private func nextCard() {
        // Determine the result based on the action taken
        let isCorrect: Bool
        if submittedAnswer {
            // User submitted an answer, use the correctness result
            isCorrect = isAnswerCorrect
        } else {
            // User pressed "don't know", count as incorrect
            isCorrect = false
        }
        
        // Add slide animation
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOffset = isCorrect ? 300 : -300
        }
        
        // Answer the card and move to next
        viewModel.answerCard(isCorrect: isCorrect)
        
        // Reset animation state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            cardOffset = 0
            showingAnswer = false
            submittedAnswer = false
            userAnswer = ""
            isAnswerCorrect = false
            
            // Check if study session is complete
            if !viewModel.hasCardsToStudy {
                showingCompletion = true
            }
        }
    }
}

#Preview {
    StudyView()
        .environmentObject(Store())
}

#Preview("Retry Mode") {
    StudyView(retryMode: true)
        .environmentObject(Store())
}
