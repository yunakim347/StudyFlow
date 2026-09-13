//
//  Item.swift
//  StudyFlow
//
//  Created by YUNA KIM on 7/24/26.
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
