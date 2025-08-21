//
//  FrequentPlayer.swift
//  LupusInFabula
//
//  Created by AI on 21/08/25.
//

import Foundation
import SwiftData

@Model
final class FrequentPlayer {
    @Attribute(.unique) var id: String
    var displayName: String
    var lastPlayedAt: Date
    var playCount: Int
    
    init(id: String = UUID().uuidString, displayName: String, lastPlayedAt: Date = Date(), playCount: Int = 1) {
        self.id = id
        self.displayName = displayName
        self.lastPlayedAt = lastPlayedAt
        self.playCount = playCount
    }
}



