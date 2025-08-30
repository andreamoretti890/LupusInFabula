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
    var allowSkipHunterRevenge: Bool
    var lastUpdated: Date
    
    // Doctor house rules
    var doctorCanSaveHimself: Bool // Can save himself once per match
    var doctorCanSaveSamePersonTwice: Bool // Can save same person in consecutive nights
    
    // Phase Timer
    var phaseTimer: Int
    static let minPhaseTimerDuration: Duration = .seconds(0)
    static let maxPhaseTimerDuration: Duration = .seconds(180)
    
    // Players
    static let minPlayers: Int = 4
    static let maxPlayers: Int = 24
    static let playersRange: ClosedRange<Double> = Double(minPlayers)...Double(maxPlayers)
    
    init(
        id: String = "default",
        allowSkipWerewolfKill: Bool = false,
        allowSkipDayVoting: Bool = false,
        allowSkipHunterRevenge: Bool = false,
        phaseTimer: Int = 0,
        lastUpdated: Date = Date(),
        doctorCanSaveHimself: Bool = false,
        doctorCanSaveSamePersonTwice: Bool = false
    ) {
        self.id = id
        self.allowSkipWerewolfKill = allowSkipWerewolfKill
        self.allowSkipDayVoting = allowSkipDayVoting
        self.allowSkipHunterRevenge = allowSkipHunterRevenge
        self.phaseTimer = phaseTimer
        self.lastUpdated = lastUpdated
        self.doctorCanSaveHimself = doctorCanSaveHimself
        self.doctorCanSaveSamePersonTwice = doctorCanSaveSamePersonTwice
    }
    
    /// Reset all settings to safe defaults
    func resetToDefaults() {
        allowSkipWerewolfKill = false
        allowSkipDayVoting = false
        allowSkipHunterRevenge = false
        phaseTimer = 0
        lastUpdated = Date()
        doctorCanSaveHimself = false
        doctorCanSaveSamePersonTwice = false
    }
    
    /// Get formatted timer text for display
    var timerDisplayText: String {
        if phaseTimer == 0 {
            return ""
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
