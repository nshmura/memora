//
//  CardsView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct CardsView: View {
    @EnvironmentObject var store: Store
    @StateObject private var viewModel = CardsViewModel()
    @State private var showingAddCard = false
    @State private var editingCard: Card?
    
    var body: some View {
        VStack(spacing: 0) {
                if !viewModel.cards.isEmpty {
                    SearchAndFilterView(viewModel: viewModel)
                }
                
                if viewModel.filteredCards.isEmpty {
                    EmptyStateView(hasCards: !viewModel.cards.isEmpty)
                } else {
                    CardListView(
                        cards: viewModel.filteredCards,
                        onEdit: { card in
                            print("✏️ Edit button tapped for card: \(card.id)")
                            editingCard = card
                        },
                        onDelete: deleteCards
                    )
                }
        }
        .navigationTitle("カード")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddCard = true
                }) {
                    Image(systemName: "plus")
                        .accessibilityLabel("新しいカードを追加")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            NavigationStack {
                AddCardView(viewModel: viewModel)
                    .id(UUID()) // 毎回新しいViewインスタンスを作成
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { editingCard != nil },
            set: { newValue in
                if !newValue {
                    print("🔄 EditCard sheet dismissed, clearing editingCard")
                    editingCard = nil
                }
            }
        )) {
            if let card = editingCard {
                NavigationStack {
                    EditCardView(card: card, viewModel: viewModel)
                        .id(card.id) // カード毎に一意のViewインスタンスを作成
                }
                .onAppear {
                    print("📱 EditCard sheet appeared with card: \(card.id)")
                }
            } else {
                Text("エラー: カードが見つかりません")
                    .onAppear {
                        print("❌ EditCard sheet appeared but editingCard is nil")
                    }
            }
        }
        .onAppear {
            viewModel.updateStore(store)
        }
    }
    
    private func deleteCards(offsets: IndexSet) {
        for index in offsets {
            let card = viewModel.filteredCards[index]
            viewModel.deleteCard(card)
        }
    }
}

struct SearchAndFilterView: View {
    @ObservedObject var viewModel: CardsViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("カードを検索...", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Tag Filter
            if !viewModel.availableTags.isEmpty {
                TagFilterView(viewModel: viewModel)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}

struct TagFilterView: View {
    @ObservedObject var viewModel: CardsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All tags button
                Button(action: {
                    viewModel.selectedTag = "全て"
                }) {
                    Text("すべて")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.selectedTag == "全て" ? Color.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(viewModel.selectedTag == "全て" ? .white : .primary)
                        .cornerRadius(16)
                }
                
                // Individual tag buttons
                ForEach(Array(viewModel.availableTags), id: \.self) { tag in
                    Button(action: {
                        viewModel.selectedTag = tag
                    }) {
                        Text(tag)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedTag == tag ? Color.accentColor : Color.gray.opacity(0.2))
                            .foregroundColor(viewModel.selectedTag == tag ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct EmptyStateView: View {
    let hasCards: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            if hasCards {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text("検索結果がありません")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                Text("検索条件を変更してください")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Image(systemName: "rectangle.on.rectangle.slash")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                Text("カードがありません")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
                
                Text("右上の + ボタンから新しいカードを追加してください")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CardListView: View {
    let cards: [Card]
    let onEdit: (Card) -> Void
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(cards) { card in
                CardRowView(card: card) {
                    onEdit(card)
                }
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(PlainListStyle())
    }
}

struct CardRowView: View {
    let card: Card
    let onEdit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Q: \(card.question)")
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("A: \(card.answer)")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 16))
                }
                .accessibilityLabel("カードを編集")
            }
            
            // Tags and Due Date
            HStack {
                if !card.tags.isEmpty {
                    TagsDisplayView(tags: card.tags)
                }
                
                Spacer()
                
                CardStatusView(card: card)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("カード: \(card.question). 回答: \(card.answer)")
    }
}

struct TagsDisplayView: View {
    let tags: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
            }
            
            if tags.count > 3 {
                Text("+\(tags.count - 3)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CardStatusView: View {
    let card: Card
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("復習: \(card.reviewCount)回")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if Calendar.current.isDateInToday(card.nextDue) {
                Text("今日")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } else if Calendar.current.isDateInTomorrow(card.nextDue) {
                Text("明日")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if card.nextDue < Date() {
                Text("復習期限")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            } else {
                Text(formatDueDate(card.nextDue))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatDueDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    CardsView()
        .environmentObject(Store())
}
