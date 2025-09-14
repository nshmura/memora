//
//  CardsView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct CardsView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationView {
            VStack {
                Text("カード一覧")
                    .font(.title)
                
                Text("カードがありません")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Add new card
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CardsView()
        .environmentObject(Store())
}
