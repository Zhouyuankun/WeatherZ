//
//  Item.swift
//  WeatherZ
//
//  Created by 周源坤 on 1/5/25.
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
