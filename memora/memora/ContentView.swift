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
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            StudyView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Study")
                }
            
            CardsView()
                .tabItem {
                    Image(systemName: "rectangle.stack")
                    Text("Cards")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
}
