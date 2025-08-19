//
//  GameSession.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData

@Model
final class GameSession {
    @Attribute(.unique) var id: String
    var startDate: Date
    var players: [Player]
    var currentPhase: String // "setup", "reveal", "night", "day", "ended"
    var currentRound: Int
    var currentPlayerIndex: Int
    var eliminatedPlayers: [String] // player IDs
    var gameHistory: [GameEvent]
    
    // Night action tracking
    var werewolfTarget: String? // player ID targeted by werewolves
    var doctorProtection: String? // player ID protected by doctor
    
    init(id: String, startDate: Date, players: [Player], currentPhase: String = "setup", currentRound: Int = 1, currentPlayerIndex: Int = 0, eliminatedPlayers: [String] = [], gameHistory: [GameEvent] = [], werewolfTarget: String? = nil, doctorProtection: String? = nil) {
        self.id = id
        self.startDate = startDate
        self.players = players
        self.currentPhase = currentPhase
        self.currentRound = currentRound
        self.currentPlayerIndex = currentPlayerIndex
        self.eliminatedPlayers = eliminatedPlayers
        self.gameHistory = gameHistory
        self.werewolfTarget = werewolfTarget
        self.doctorProtection = doctorProtection
    }
}

struct Player: Codable {
    var id: String
    var displayName: String
    var roleID: String
    var isAlive: Bool
    
    init(id: String, displayName: String, roleID: String, isAlive: Bool = true) {
        self.id = id
        self.displayName = displayName
        self.roleID = roleID
        self.isAlive = isAlive
    }
}

struct GameEvent: Codable {
    var id: String
    var timestamp: Date
    var type: String // "player_eliminated", "role_action", "vote_result"
    var description: String
    var playerID: String?
    var targetPlayerID: String?
    
    init(id: String, timestamp: Date, type: String, description: String, playerID: String? = nil, targetPlayerID: String? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.description = description
        self.playerID = playerID
        self.targetPlayerID = targetPlayerID
    }
}
