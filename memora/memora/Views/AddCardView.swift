//
//  AddCardView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: CardsViewModel
    
    @State private var question = ""
    @State private var answer = ""
    @State private var tagInput = ""
    @State private var selectedTags: Set<String> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Question Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("問題")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("問題を入力してください", text: $question, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .accessibilityLabel("問題入力欄")
                    }
                    
                    // Answer Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("回答")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("回答を入力してください", text: $answer, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                            .accessibilityLabel("回答入力欄")
                    }
                    
                    // Tag Input Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("タグ")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("タグを入力してEnter", text: $tagInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    addTag()
                                }
                                .accessibilityLabel("タグ入力欄")
                            
                            Button("追加") {
                                addTag()
                            }
                            .disabled(tagInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        // Selected Tags
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
                        
                        // Existing Tags Suggestions
                        if !viewModel.availableTags.isEmpty {
                            Text("既存のタグ:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(viewModel.availableTags).sorted(), id: \.self) { tag in
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
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("新しいカード")
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
        
        viewModel.addCard(
            question: trimmedQuestion,
            answer: trimmedAnswer,
            tags: Array(selectedTags)
        )
        dismiss()
    }
}

#Preview {
    AddCardView(viewModel: CardsViewModel())
}