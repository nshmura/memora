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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.hasCardsToStudy {
                    studyContent
                } else {
                    emptyState
                }
            }
            .navigationTitle("Study")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.updateStore(store)
            }
            .alert("学習完了！", isPresented: $showingCompletion) {
                Button("OK") {
                    Task {
                        let notificationPlanner = NotificationPlanner()
                        let granted = await notificationPlanner.requestAuthorization()
                        if granted {
                            print("Notification permission granted")
                        } else {
                            print("Notification permission denied")
                        }
                    }
                }
            } message: {
                Text("今日の復習が完了しました。お疲れ様でした！")
            }
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
                
                // Show Answer button or Answer content
                if showingAnswer {
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
                } else {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingAnswer = true
                            viewModel.showAnswer()
                        }
                    }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("答えを見る")
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
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if showingAnswer {
                HStack(spacing: 12) {
                    // Don't Know button
                    Button(action: {
                        answerCard(isCorrect: false)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                                .font(.title2)
                            Text("分からない")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 1)
                        )
                    }
                    
                    // Incorrect button
                    Button(action: {
                        answerCard(isCorrect: false)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "xmark.circle")
                                .font(.title2)
                            Text("不正解")
                                .font(.caption)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    
                    // Correct button
                    Button(action: {
                        answerCard(isCorrect: true)
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                                .font(.title2)
                            Text("正解")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.green, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 20)
            } else {
                Text("まずは答えを確認してください")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("今日の復習は完了しました！")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("お疲れ様でした。明日も頑張りましょう。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    private func answerCard(isCorrect: Bool) {
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
