//
//  Item.swift
//  TRPG Encounter
//
//  Created by Aleksei Kishinskii on 15. 6. 2025..
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
