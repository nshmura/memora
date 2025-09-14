//
//  Settings.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation

struct Settings: Codable {
    var intervals: [Int] = [0, 1, 2, 4, 7, 15, 30]
    var morningHour: Int = 8
    var timeZoneIdentifier: String = "Asia/Tokyo"
    
    init() {
        // Use default values
    }
}
