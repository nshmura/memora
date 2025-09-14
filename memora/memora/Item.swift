//
//  Item.swift
//  memora
//
//  Created by 西村真一 on 2025/09/14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
