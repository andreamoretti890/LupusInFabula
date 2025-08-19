//
//  GameService.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

enum GamePhase: Hashable {
    case setup
    case reveal
    case night
    case day
}

@Observable
class GameService {
    private var modelContext: ModelContext
    
    // Game state
    var currentSession: GameSession?
    var availableRoles: [Role] = []
    var availablePresets: [RolePreset] = []
    var lastSavedConfig: SavedConfig?
    var gameSettings: GameSettings?
    
    // Setup state
    var playerCount: Int = 8
    var selectedRoles: [RoleCount] = []
    var selectedPreset: RolePreset?
    
    // Reveal state
    var currentRevealPlayerIndex: Int = 0
    var isRevealing: Bool = false
    
    // Navigation state
    var navigationPath = NavigationPath()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
        loadData()
    }
    
    private func loadData() {
        // Load roles and presets from SwiftData
        let roleDescriptor = FetchDescriptor<Role>()
        let presetDescriptor = FetchDescriptor<RolePreset>()
        let configDescriptor = FetchDescriptor<SavedConfig>()
        let settingsDescriptor = FetchDescriptor<GameSettings>()
        
        do {
            availableRoles = try modelContext.fetch(roleDescriptor)
            availablePresets = try modelContext.fetch(presetDescriptor)
            let configs = try modelContext.fetch(configDescriptor)
            lastSavedConfig = configs.first
            
            let settings = try modelContext.fetch(settingsDescriptor)
            gameSettings = settings.first
        } catch {
            print("Error loading data: \(error)")
        }
        
        // Seed data if empty
        if availableRoles.isEmpty {
            seedRoles()
        }
        if availablePresets.isEmpty {
            seedPresets()
        }
    }
    
    private func seedRoles() {
        let roles = [
            Role(id: "werewolf", name: "Werewolf", alignment: "Werewolf", abilities: ["Kill at night"], isUnique: false, minPlayers: 4, notes: "Choose a villager to kill each night", emoji: "🐺"),
            Role(id: "villager", name: "Villager", alignment: "Villager", abilities: ["Vote during day"], isUnique: false, minPlayers: 1, notes: "Vote to eliminate suspected werewolves", emoji: "👤"),
            Role(id: "seer", name: "Seer", alignment: "Villager", abilities: ["Check alignment at night"], isUnique: true, minPlayers: 6, notes: "Learn if a player is a werewolf", emoji: "🔮"),
            Role(id: "doctor", name: "Doctor", alignment: "Villager", abilities: ["Protect at night"], isUnique: true, minPlayers: 8, notes: "Save a player from werewolf attack", emoji: "💊"),
            Role(id: "hunter", name: "Hunter", alignment: "Villager", abilities: ["Kill when eliminated"], isUnique: true, minPlayers: 10, notes: "Take revenge when eliminated", emoji: "🏹")
        ]
        
        for role in roles {
            modelContext.insert(role)
        }
        
        do {
            try modelContext.save()
            availableRoles = roles
        } catch {
            print("Error seeding roles: \(error)")
        }
    }
    
    private func seedPresets() {
        let presets = [
            RolePreset(
                id: "classic_6",
                name: "Classic (6 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 2),
                    RoleCount(roleID: "villager", count: 3),
                    RoleCount(roleID: "seer", count: 1)
                ],
                minPlayers: 6,
                maxPlayers: 6,
                presetDescription: "Perfect for beginners"
            ),
            RolePreset(
                id: "classic_8",
                name: "Classic (8 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 2),
                    RoleCount(roleID: "villager", count: 4),
                    RoleCount(roleID: "seer", count: 1),
                    RoleCount(roleID: "doctor", count: 1)
                ],
                minPlayers: 8,
                maxPlayers: 8,
                presetDescription: "Balanced gameplay"
            ),
            RolePreset(
                id: "advanced_12",
                name: "Advanced (12 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 3),
                    RoleCount(roleID: "villager", count: 6),
                    RoleCount(roleID: "seer", count: 1),
                    RoleCount(roleID: "doctor", count: 1),
                    RoleCount(roleID: "hunter", count: 1)
                ],
                minPlayers: 12,
                maxPlayers: 12,
                presetDescription: "Complex strategy required"
            )
        ]
        
        for preset in presets {
            modelContext.insert(preset)
        }
        
        do {
            try modelContext.save()
            availablePresets = presets
        } catch {
            print("Error seeding presets: \(error)")
        }
    }
    
    func selectPreset(_ preset: RolePreset) {
        selectedPreset = preset
        playerCount = preset.minPlayers
        selectedRoles = preset.roleCounts
    }
    
    func updateRoleCount(roleID: String, count: Int) {
        if let index = selectedRoles.firstIndex(where: { $0.roleID == roleID }) {
            selectedRoles[index].count = count
        } else {
            selectedRoles.append(RoleCount(roleID: roleID, count: count))
        }
        
        // Remove zero counts
        selectedRoles.removeAll { $0.count <= 0 }
    }
    
    func getRoleCount(roleID: String) -> Int {
        return selectedRoles.first { $0.roleID == roleID }?.count ?? 0
    }
    
    func getTotalSelectedRoles() -> Int {
        return selectedRoles.reduce(0) { $0 + $1.count }
    }
    
    func isSetupValid() -> Bool {
        let total = getTotalSelectedRoles()
        return total == playerCount && total >= 4
    }
    
    func startGame() {
        guard isSetupValid() else { 
            print("Game setup is not valid")
            return 
        }
        
        print("Starting game with \(playerCount) players")
        
        // Create players
        var players: [Player] = []
        var rolePool: [String] = []
        
        // Build role pool
        for roleCount in selectedRoles {
            for _ in 0..<roleCount.count {
                rolePool.append(roleCount.roleID)
            }
        }
        
        print("Role pool: \(rolePool)")
        
        // Shuffle and assign roles
        rolePool.shuffle()
        
        for i in 0..<playerCount {
            let player = Player(
                id: UUID().uuidString,
                displayName: "Player \(i + 1)",
                roleID: rolePool[i]
            )
            players.append(player)
        }
        
        print("Created \(players.count) players")
        
        // Create game session
        let session = GameSession(
            id: UUID().uuidString,
            startDate: Date(),
            players: players,
            currentPhase: "reveal"
        )
        
        currentSession = session
        modelContext.insert(session)
        
        print("Created session with ID: \(session.id)")
        print("Session phase: \(session.currentPhase)")
        print("Session players: \(session.players.count)")
        
        // Save configuration
        let config = SavedConfig(
            id: UUID().uuidString,
            date: Date(),
            playersCount: playerCount,
            roleSelection: selectedRoles,
            presetID: selectedPreset?.id
        )
        
        if let existingConfig = lastSavedConfig {
            modelContext.delete(existingConfig)
        }
        
        modelContext.insert(config)
        lastSavedConfig = config
        
        do {
            try modelContext.save()
            print("Game saved successfully")
            
            // Navigate to reveal phase
            navigationPath.append(GamePhase.reveal)
        } catch {
            print("Error saving game: \(error)")
        }
    }
    
    func getCurrentPlayer() -> Player? {
        guard let session = currentSession,
              currentRevealPlayerIndex < session.players.count else { return nil }
        return session.players[currentRevealPlayerIndex]
    }
    
    func getCurrentPlayerRole() -> Role? {
        guard let player = getCurrentPlayer() else { return nil }
        return availableRoles.first { $0.id == player.roleID }
    }
    
    func nextPlayer() {
        guard let session = currentSession else { return }
        
        currentRevealPlayerIndex += 1
        
        if currentRevealPlayerIndex >= session.players.count {
            // All players have seen their roles, start the game
            session.currentPhase = "night"
            currentRevealPlayerIndex = 0
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving session: \(error)")
            }
        }
    }
    
    func isRevealComplete() -> Bool {
        guard let session = currentSession else { return false }
        return currentRevealPlayerIndex >= session.players.count
    }
    
    // Development/Testing function to skip reveal phase
    func skipRevealPhase() {
        guard let session = currentSession else { return }
        
        // Set reveal as complete
        currentRevealPlayerIndex = session.players.count
        
        // Update session phase to night
        session.currentPhase = "night"
        
        // Save the changes
        do {
            try modelContext.save()
            print("Skipped reveal phase - moving to night")
            
            // Navigate to night phase
            navigateToNight()
        } catch {
            print("Error saving after skipping reveal: \(error)")
        }
    }
    
    func navigateToSetup() {
        navigationPath.append(GamePhase.setup)
    }
    
    func navigateToNight() {
        navigationPath.append(GamePhase.night)
    }
    
    func navigateToDay() {
        navigationPath.append(GamePhase.day)
    }
    
    func resetNavigation() {
        navigationPath = NavigationPath()
    }
    
    // Development/Testing function to quickly restart the game
    func quickRestartGame() {
        // Reset all game state
        currentSession = nil
        currentRevealPlayerIndex = 0
        isRevealing = false
        
        // Clear navigation and go back to home
        navigationPath = NavigationPath()
        
        print("Game restarted for development/testing")
    }
    
    func getAlivePlayers() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive }
    }
    
    func getEliminatedPlayers() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { !$0.isAlive }
    }
    
    func isPlayerEliminated(_ player: Player) -> Bool {
        guard let session = currentSession else { return false }
        return session.eliminatedPlayers.contains(player.id)
    }
    
    func getWerewolves() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive && $0.roleID == "werewolf" }
    }
    
    func getVillagers() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive && $0.roleID != "werewolf" }
    }
    
    func eliminatePlayer(_ player: Player) {
        guard let session = currentSession else { return }
        
        // Add to eliminated players list
        if !session.eliminatedPlayers.contains(player.id) {
            session.eliminatedPlayers.append(player.id)
        }
        
        // Update the player in the session's players array
        if let playerIndex = session.players.firstIndex(where: { $0.id == player.id }) {
            session.players[playerIndex].isAlive = false
        }
        
        // Add game event
        let event = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "player_eliminated",
            description: "\(player.displayName) was eliminated",
            playerID: player.id
        )
        session.gameHistory.append(event)
        
        // Save the changes
        do {
            try modelContext.save()
            print("Player \(player.displayName) has been eliminated")
        } catch {
            print("Error saving player elimination: \(error)")
        }
    }
    
    func setWerewolfTarget(_ player: Player) {
        guard let session = currentSession else { return }
        session.werewolfTarget = player.id
        
        // Add game event for tracking
        let event = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "werewolf_target",
            description: "Werewolves targeted \(player.displayName)",
            targetPlayerID: player.id
        )
        session.gameHistory.append(event)
        
        do {
            try modelContext.save()
            print("Werewolves targeted \(player.displayName)")
        } catch {
            print("Error saving werewolf target: \(error)")
        }
    }
    
    func setDoctorProtection(_ player: Player) {
        guard let session = currentSession else { return }
        session.doctorProtection = player.id
        
        // Add game event for tracking
        let event = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "doctor_protection",
            description: "Doctor protected \(player.displayName)",
            targetPlayerID: player.id
        )
        session.gameHistory.append(event)
        
        do {
            try modelContext.save()
            print("Doctor protected \(player.displayName)")
        } catch {
            print("Error saving doctor protection: \(error)")
        }
    }
    
    func resolveNightActions() {
        guard let session = currentSession else { return }
        
        // Check if werewolf target was protected by doctor
        if let werewolfTargetID = session.werewolfTarget {
            let isProtected = session.doctorProtection == werewolfTargetID
            
            if !isProtected {
                // Find the targeted player and eliminate them
                if let targetPlayer = session.players.first(where: { $0.id == werewolfTargetID }) {
                    eliminatePlayer(targetPlayer)
                }
            } else {
                // Add event for successful protection
                if let targetPlayer = session.players.first(where: { $0.id == werewolfTargetID }) {
                    let event = GameEvent(
                        id: UUID().uuidString,
                        timestamp: Date(),
                        type: "player_saved",
                        description: "\(targetPlayer.displayName) was saved by the doctor",
                        targetPlayerID: targetPlayer.id
                    )
                    session.gameHistory.append(event)
                }
            }
        }
        
        // Reset night action tracking for next round
        session.werewolfTarget = nil
        session.doctorProtection = nil
        
        do {
            try modelContext.save()
            print("Night actions resolved")
        } catch {
            print("Error saving night resolution: \(error)")
        }
    }
    
    func checkWinCondition() -> String? {
        let werewolves = getWerewolves()
        let villagers = getVillagers()
        
        if werewolves.isEmpty {
            return "Villagers win! All werewolves have been eliminated."
        }
        
        if werewolves.count >= villagers.count {
            return "Werewolves win! They outnumber the villagers."
        }
        
        return nil
    }
    
    func endGameAndReturnHome() {
        // Reset all game state
        currentSession = nil
        currentRevealPlayerIndex = 0
        isRevealing = false
        
        // Clear navigation and go back to home
        navigationPath = NavigationPath()
        
        print("Game ended - returning to home")
    }
    
    // Development helper function to debug game state
    func printGameState() {
        guard let session = currentSession else {
            print("No active game session")
            return
        }
        
        print("\n=== GAME STATE DEBUG ===")
        print("Phase: \(session.currentPhase)")
        print("Round: \(session.currentRound)")
        print("Total Players: \(session.players.count)")
        print("Alive Players: \(getAlivePlayers().count)")
        print("Eliminated Players: \(getEliminatedPlayers().count)")
        print("Werewolves Alive: \(getWerewolves().count)")
        print("Villagers Alive: \(getVillagers().count)")
        
        print("\nPlayers:")
        for player in session.players {
            let status = player.isAlive ? "ALIVE" : "DEAD"
            print("- \(player.displayName) (\(player.roleID)) - \(status)")
        }
        print("========================\n")
    }
}
