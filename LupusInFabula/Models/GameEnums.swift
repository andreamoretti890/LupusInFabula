//
//  GameEnums.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftUI

// MARK: - Role Alignment
enum RoleAlignment: String, CaseIterable, Codable {
    case villager = "Villager"
    case werewolf = "Werewolf"
    case neutral = "Neutral"
    
    var color: Color {
        switch self {
        case .villager: return .green
        case .werewolf: return .red
        case .neutral: return .orange
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Role ID
enum RoleID: String, CaseIterable, Codable {
    case werewolf = "werewolf"
    case villager = "villager"
    case seer = "seer"
    case doctor = "doctor"
    case hunter = "hunter"
    case jester = "jester"
    case medium = "medium"
    case mayor = "mayor"
    
    var defaultName: String {
        switch self {
        case .werewolf: return "Werewolf"
        case .villager: return "Villager"
        case .seer: return "Seer"
        case .doctor: return "Doctor"
        case .hunter: return "Hunter"
        case .jester: return "Jester"
        case .medium: return "Medium"
        case .mayor: return "Mayor"
        }
    }
    
    var defaultEmoji: String {
        switch self {
        case .werewolf: return "🐺"
        case .villager: return "👨🏻"
        case .seer: return "🔮"
        case .doctor: return "💊"
        case .hunter: return "🏹"
        case .jester: return "🃏"
        case .medium: return "👻"
        case .mayor: return "🏛️"
        }
    }
    
    var alignment: RoleAlignment {
        switch self {
        case .werewolf: return .werewolf
        case .villager, .seer, .doctor, .hunter, .medium, .mayor: return .villager
        case .jester: return .neutral
        }
    }
    
    var defaultAbilities: [String] {
        switch self {
        case .werewolf: return ["Kill at night"]
        case .villager: return ["Vote during day"]
        case .seer: return ["Check alignment at night"]
        case .doctor: return ["Protect at night"]
        case .hunter: return ["Kill when eliminated"]
        case .jester: return ["Win by being voted out"]
        case .medium: return ["Check eliminated players at night"]
        case .mayor: return ["Vote during day", "Village leadership"]
        }
    }
    
    var isUnique: Bool {
        switch self {
        case .werewolf, .villager: return false
        case .seer, .doctor, .hunter, .jester, .medium, .mayor: return true
        }
    }
    
    var minPlayers: Int {
        switch self {
        case .villager: return 1
        case .werewolf: return 4
        case .seer: return 6
        case .jester: return 7
        case .doctor, .medium: return 8
        case .mayor: return 9
        case .hunter: return 10
        }
    }
    
    var defaultNotes: String {
        switch self {
        case .werewolf: return "Choose a villager to kill each night"
        case .villager: return "Vote to eliminate suspected werewolves"
        case .seer: return "Learn if a player is a werewolf"
        case .doctor: return "Save a player from werewolf attack"
        case .hunter: return "Take revenge when eliminated"
        case .jester: return "Wins the game by being voted out during the day phase"
        case .medium: return "During night, check if an eliminated player was a werewolf or not"
        case .mayor: return "A respected village leader who votes during the day phase"
        }
    }
}

// MARK: - Game Phase
enum GamePhase: String, Hashable {
    case setup = "setup"
    case reveal = "reveal"
    case night = "night"
    case day = "day"
}

// MARK: - Night Action Type (already exists in NightPhaseView, should be moved here)
enum NightActionType {
    case werewolf
    case seer
    case doctor
    case medium
    case hunter
}
