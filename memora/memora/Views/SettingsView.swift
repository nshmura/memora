//
//  SettingsView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @StateObject private var settingsViewModel: SettingsViewModel
    
    init() {
        // Initialize with default Store - will be replaced by environment injection
        self._settingsViewModel = StateObject(wrappedValue: SettingsViewModel())
    }
    
    var body: some View {
        List {
                Section(header: Text("通知設定")) {
                    // Notification Time Setting
                    HStack {
                        Text("通知時刻")
                        Spacer()
                        Picker("通知時刻", selection: Binding(
                            get: { settingsViewModel.morningHour },
                            set: { settingsViewModel.updateMorningHour($0) }
                        )) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour))
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    
                    // Notification Status
                    HStack {
                        Text("通知ステータス")
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(settingsViewModel.notificationStatusString)
                                .font(.caption)
                                .foregroundColor(settingsViewModel.notificationPermissionStatus == .authorized ? .green : .red)
                            
                            if settingsViewModel.notificationPermissionStatus != .authorized {
                                Button("許可を求める") {
                                    Task {
                                        await settingsViewModel.requestNotificationPermission()
                                    }
                                }
                                .font(.caption2)
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    if settingsViewModel.notificationPermissionStatus == .authorized {
                        Toggle("通知を有効にする", isOn: Binding(
                            get: { settingsViewModel.notificationEnabled },
                            set: { settingsViewModel.updateNotificationEnabled($0) }
                        ))
                        .font(.subheadline)
                    } else {
                        Text("復習のリマインダー通知を受け取るには、通知を許可してください。")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("外観設定")) {
                    HStack {
                        Text("テーマ")
                        Spacer()
                        Picker("テーマ", selection: Binding(
                            get: { store.settings.theme },
                            set: { newTheme in
                                store.settings.theme = newTheme
                                store.saveSettings()
                            }
                        )) {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.displayName)
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section(header: Text("学習間隔設定")) {
                    HStack {
                        Text("間隔テーブル")
                        Spacer()
                        Text(settingsViewModel.intervals.map(String.init).joined(separator: ", ") + "日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("カードの復習間隔です。正解時に次の段階に進みます。")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("アプリ情報")) {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("アプリについて")
                        Spacer()
                        Text("Memora - 間隔反復学習アプリ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        .navigationTitle("設定")
        .onAppear {
            // Update ViewModel to use environment Store
            settingsViewModel.updateStore(store)
        }
        .task {
            await settingsViewModel.checkNotificationPermissions()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Store())
}
