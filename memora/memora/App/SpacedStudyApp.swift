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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
