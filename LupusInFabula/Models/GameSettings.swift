//
//  GameSettings.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData

@Model
final class GameSettings {
    @Attribute(.unique) var id: String
    var allowSkipWerewolfKill: Bool
    var allowSkipDayVoting: Bool
    var phaseTimer: Int // 0 = disabled, else seconds (30-180)
    var lastUpdated: Date
    
    init(
        id: String = "default",
        allowSkipWerewolfKill: Bool = false,
        allowSkipDayVoting: Bool = false,
        phaseTimer: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.allowSkipWerewolfKill = allowSkipWerewolfKill
        self.allowSkipDayVoting = allowSkipDayVoting
        self.phaseTimer = phaseTimer
        self.lastUpdated = lastUpdated
    }
    
    /// Reset all settings to safe defaults
    func resetToDefaults() {
        allowSkipWerewolfKill = false
        allowSkipDayVoting = false
        phaseTimer = 0
        lastUpdated = Date()
    }
    
    /// Get formatted timer text for display
    var timerDisplayText: String {
        if phaseTimer == 0 {
            return "Disabled"
        } else {
            let minutes = phaseTimer / 60
            let seconds = phaseTimer % 60
            if minutes > 0 {
                return "\(minutes)m \(seconds)s"
            } else {
                return "\(seconds)s"
            }
        }
    }
}
