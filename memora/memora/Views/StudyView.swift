//
//  StudyView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct StudyView: View {
    @EnvironmentObject var store: Store
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("学習画面")
                    .font(.title)
                
                Text("復習するカードがありません")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("Study")
            .padding()
        }
    }
}

#Preview {
    StudyView()
        .environmentObject(Store())
}
