//
//  MemoraApp.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

@main
struct MemoraApp: App {
    @StateObject private var store = Store()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    store.loadData()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .background:
                        // アプリがバックグラウンドに入る時にデータを保存
                        store.saveCards()
                        store.saveSettings()
                        store.saveReviewLogs()
                    case .active:
                        // アプリがアクティブになった時に通知を再編成
                        let notificationPlanner = NotificationPlanner()
                        notificationPlanner.reorganizeNotifications()
                    default:
                        break
                    }
                }
        }
    }
}
