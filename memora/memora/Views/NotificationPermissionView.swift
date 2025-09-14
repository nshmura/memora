//
//  NotificationPermissionView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct NotificationPermissionView: View {
    let onComplete: (Bool) -> Void
    @State private var isRequesting = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("復習通知を有効にしましょう")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "clock")
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("最適なタイミングで通知")
                            .fontWeight(.medium)
                        Text("忘却曲線に基づいて、復習が必要なタイミングで通知をお送りします")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("学習効果を最大化")
                            .fontWeight(.medium)
                        Text("継続的な学習をサポートし、記憶の定着を促進します")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.blue)
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("いつでも設定変更可能")
                            .fontWeight(.medium)
                        Text("通知時間や設定は後から自由に変更できます")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                Button(action: requestPermission) {
                    HStack {
                        if isRequesting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundStyle(.white)
                        }
                        Text(isRequesting ? "許可を要求中..." : "通知を有効にする")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isRequesting)
                
                Button("後で設定する") {
                    onComplete(false)
                }
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
        }
        .padding(24)
        .background(.background)
    }
    
    private func requestPermission() {
        isRequesting = true
        
        Task {
            let notificationPlanner = NotificationPlanner()
            let granted = await notificationPlanner.requestAuthorization()
            
            await MainActor.run {
                isRequesting = false
                onComplete(granted)
            }
        }
    }
}

#Preview {
    NotificationPermissionView { granted in
        print("Permission granted: \(granted)")
    }
}