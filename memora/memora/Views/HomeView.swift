//
//  HomeView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("今日の復習")
                    .font(.title2)
                
                Text("0枚")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("🔥 連続日数: 0日")
                    .font(.headline)
                
                Button("学習を始める") {
                    // TODO: Navigate to Study
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Text("次回通知: 設定してください")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Memora")
            .padding()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(Store())
}
