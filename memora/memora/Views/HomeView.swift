//
//  HomeView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: Store
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("今日の復習")
                    .font(.title2)
                
                Text("\(viewModel.todayReviewCount)枚")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("🔥 連続日数: \(viewModel.consecutiveDays)日")
                    .font(.headline)
                
                Button("学習を始める") {
                    // TODO: Navigate to StudyView
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .disabled(viewModel.todayReviewCount == 0)
                
                Text("次回通知: \(viewModel.nextNotificationTime)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Memora")
            .padding()
            .onAppear {
                viewModel.updateStore(store)
                viewModel.refresh()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(Store())
}
