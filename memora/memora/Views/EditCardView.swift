//
//  EditCardView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    let card: Card
    let viewModel: CardsViewModel
    
    @State private var question: String
    @State private var answer: String
    @State private var tagInput = ""
    @State private var selectedTags: Set<String>
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteConfirmation = false
    
    init(card: Card, viewModel: CardsViewModel) {
        print("🔍 EditCardView.init - card.id: \(card.id)")
        print("🔍 EditCardView.init - question: \(card.question)")
        print("🔍 EditCardView.init - answer: \(card.answer)")
        print("🔍 EditCardView.init - tags: \(card.tags)")
        
        self.card = card
        self.viewModel = viewModel
        self._question = State(initialValue: card.question)
        self._answer = State(initialValue: card.answer)
        self._selectedTags = State(initialValue: Set(card.tags))
    }
    
    var body: some View {
        // デバッグ用のZStack
        ZStack {
            Color.clear
                .onAppear {
                    print("🎯 EditCardView.body.onAppear - card.id: \(card.id)")
                    print("🎯 EditCardView.body.onAppear - @State question: \(question)")
                    print("🎯 EditCardView.body.onAppear - @State answer: \(answer)")
                }
            
            Form {
                CardInfoView(card: card)
                
                QuestionInputView(question: $question)
                
                AnswerInputView(answer: $answer)
                
                TagInputView(
                    tagInput: $tagInput,
                    selectedTags: $selectedTags,
                    availableTags: viewModel.availableTags,
                    onAddTag: {
                        addTag()
                    }
                )
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            print("🚀 EditCardView appeared - card: \(card.id)")
        }
        .onDisappear {
            print("👋 EditCardView disappeared - card: \(card.id)")
        }
        .navigationTitle("カードを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveCard()
                }
                .disabled(!isFormValid)
                .fontWeight(.semibold)
            }
        }
        .alert("エラー", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("カードを削除しますか？", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                deleteCard()
            }
            Button("キャンセル", role: .cancel) { }
        } message: {
            Text("この操作は取り消せません。")
        }
    }
    
    private var isFormValid: Bool {
        !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addTag() {
        let newTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !newTag.isEmpty && !selectedTags.contains(newTag) {
            selectedTags.insert(newTag)
            tagInput = ""
        }
    }
    
    private func saveCard() {
        let trimmedQuestion = question.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAnswer = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuestion.isEmpty, !trimmedAnswer.isEmpty else {
            alertMessage = "問題と回答の両方を入力してください。"
            showingAlert = true
            return
        }
        
        // Preserve the original card's metadata and update only the editable fields
        var updatedCard = card
        updatedCard.question = trimmedQuestion
        updatedCard.answer = trimmedAnswer
        updatedCard.tags = Array(selectedTags)
        
        viewModel.updateCard(updatedCard)
        dismiss()
    }
    
    private func deleteCard() {
        viewModel.deleteCard(card)
        dismiss()
    }
    
    private func formatDate(_ hash: Int) -> String {
        // Simple date approximation based on hash for display purposes
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}

#Preview {
    var sampleCard = Card(
        question: "サンプル問題",
        answer: "サンプル回答",
        tags: ["サンプル", "テスト"]
    )
    // Simulate an existing card with some history
    sampleCard.stepIndex = 1
    sampleCard.reviewCount = 3
    sampleCard.nextDue = Date()
    sampleCard.lastResult = true
    
    return EditCardView(card: sampleCard, viewModel: CardsViewModel())
}

// MARK: - Separate View Components

private struct CardInfoView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("カード情報")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("作成日: \(formatDate(card.id.uuidString.hash))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("復習回数: \(card.reviewCount)回")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if Calendar.current.isDateInToday(card.nextDue) {
                    Text("次回復習: 今日")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                } else if Calendar.current.isDateInTomorrow(card.nextDue) {
                    Text("次回復習: 明日")
                        .font(.caption)
                        .foregroundColor(.orange)
                } else if card.nextDue < Date() {
                    Text("次回復習: 復習期限")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                } else {
                    Text("次回復習: \(formattedNextDueDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .cornerRadius(8)
        }
    }
    
    private var formattedNextDueDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: card.nextDue)
    }
    
    private func formatDate(_ hash: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: Date())
    }
}

private struct QuestionInputView: View {
    @Binding var question: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("問題")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("問題を入力してください", text: $question, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .accessibilityLabel("問題入力欄")
        }
    }
}

private struct AnswerInputView: View {
    @Binding var answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("回答")
                .font(.headline)
                .foregroundColor(.primary)
            
            TextField("回答を入力してください", text: $answer, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
                .accessibilityLabel("回答入力欄")
        }
    }
}

private struct TagInputView: View {
    @Binding var tagInput: String
    @Binding var selectedTags: Set<String>
    let availableTags: [String]
    let onAddTag: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("タグ")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                TextField("タグを入力してEnter", text: $tagInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        onAddTag()
                    }
                    .accessibilityLabel("タグ入力欄")
                
                Button("追加") {
                    onAddTag()
                }
                .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            SelectedTagsView(selectedTags: $selectedTags)
            AvailableTagsView(selectedTags: $selectedTags, availableTags: availableTags)
        }
    }
}

private struct SelectedTagsView: View {
    @Binding var selectedTags: Set<String>
    
    var body: some View {
        if !selectedTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(selectedTags).sorted(), id: \.self) { tag in
                        HStack(spacing: 4) {
                            Text(tag)
                                .font(.caption)
                            
                            Button(action: {
                                selectedTags.remove(tag)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("\(tag)タグを削除")
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct AvailableTagsView: View {
    @Binding var selectedTags: Set<String>
    let availableTags: [String]
    
    var body: some View {
        if !availableTags.isEmpty {
            Text("既存のタグ:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(availableTags).sorted(), id: \.self) { tag in
                        Button(action: {
                            if !selectedTags.contains(tag) {
                                selectedTags.insert(tag)
                            }
                        }) {
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedTags.contains(tag) ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                                .foregroundColor(selectedTags.contains(tag) ? .blue : .primary)
                                .cornerRadius(12)
                        }
                        .disabled(selectedTags.contains(tag))
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct DeleteButtonView: View {
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onDelete) {
            HStack {
                Image(systemName: "trash")
                Text("カードを削除")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .cornerRadius(8)
        }
        .accessibilityLabel("カードを削除")
    }
}