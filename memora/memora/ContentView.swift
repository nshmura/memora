//
//  ContentView.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store

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
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
}
