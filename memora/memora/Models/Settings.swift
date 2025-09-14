//
//  Settings.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    var displayName: String {
        switch self {
        case .system:
            return "OSに合わせる"
        case .light:
            return "ライトモード"
        case .dark:
            return "ダークモード"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct Settings: Codable {
    var intervals: [Int] = [0, 1, 2, 4, 7, 15, 30]
    var morningHour: Int = 8
    var timeZoneIdentifier: String = "Asia/Tokyo"
    var hasShownNotificationPrompt: Bool = false
    var theme: AppTheme = .light
    var notificationEnabled: Bool = true
    
    init() {
        // Use default values
    }
}
