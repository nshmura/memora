//
//  SettingsView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("設定")
                    .font(.title)
                
                HStack {
                    Text("通知時刻:")
                    Spacer()
                    Text("08:00")
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading) {
                    Text("間隔テーブル:")
                    Text("0,1,2,4,7,15,30日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .navigationTitle("Settings")
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Store())
}
