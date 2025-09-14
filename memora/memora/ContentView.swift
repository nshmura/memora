//
//  ContentView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var showNotificationPrompt = false

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("ホーム")
            }
            
            NavigationStack {
                CardsView()
            }
            .tabItem {
                Image(systemName: "rectangle.stack")
                Text("カード")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape")
                Text("設定")
            }
        }
        .preferredColorScheme(store.settings.theme.colorScheme)
        .onAppear {
            checkAndShowNotificationPrompt()
            // デバッグ用：ファイルアプリに表示するためのテストデータを作成
            store.createTestData()
        }
        .sheet(isPresented: $showNotificationPrompt) {
            NotificationPermissionView { granted in
                store.settings.hasShownNotificationPrompt = true
                store.saveSettings()
                showNotificationPrompt = false
                
                if granted {
                    // 通知が許可された場合、初期通知をスケジュール
                    let notificationPlanner = NotificationPlanner()
                    notificationPlanner.reorganizeNotifications()
                }
            }
        }
    }
    
    private func checkAndShowNotificationPrompt() {
        // 初回起動時かつ通知プロンプトを表示していない場合
        if !store.settings.hasShownNotificationPrompt {
            // 少し遅延させてから表示（アプリの初期化完了後）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showNotificationPrompt = true
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
}
