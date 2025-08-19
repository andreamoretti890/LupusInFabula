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
    var includeJester: Bool = false
    
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
            
            print("Loaded \(availableRoles.count) roles from database:")
            for role in availableRoles {
                print("- \(role.name) (\(role.id))")
            }
        } catch {
            print("Error loading data: \(error)")
        }
        
        // Seed data if empty or force refresh if we have missing roles
        let expectedRoleIds = ["werewolf", "villager", "seer", "doctor", "hunter", "jester", "medium"]
        let currentRoleIds = Set(availableRoles.map { $0.id })
        let missingRoles = expectedRoleIds.filter { !currentRoleIds.contains($0) }
        
        if availableRoles.isEmpty || !missingRoles.isEmpty {
            print("Missing roles: \(missingRoles). Re-seeding...")
            // Clear existing roles and re-seed
            clearAndReseedRoles()
        }
        
        if availablePresets.isEmpty {
            seedPresets()
        }
        if gameSettings == nil {
            seedDefaultSettings()
        }
    }
    
    private func clearAndReseedRoles() {
        // Delete all existing roles
        do {
            let allRoles = try modelContext.fetch(FetchDescriptor<Role>())
            for role in allRoles {
                modelContext.delete(role)
            }
            try modelContext.save()
            print("Cleared \(allRoles.count) existing roles")
        } catch {
            print("Error clearing existing roles: \(error)")
        }
        
        // Re-seed with fresh roles
        seedRoles()
    }
    
    private func seedRoles() {
        let roles = [
            Role(id: "werewolf", name: "Werewolf", alignment: "Werewolf", abilities: ["Kill at night"], isUnique: false, minPlayers: 4, notes: "Choose a villager to kill each night", emoji: "🐺"),
            Role(id: "villager", name: "Villager", alignment: "Villager", abilities: ["Vote during day"], isUnique: false, minPlayers: 1, notes: "Vote to eliminate suspected werewolves", emoji: "👨🏻"),
            Role(id: "seer", name: "Seer", alignment: "Villager", abilities: ["Check alignment at night"], isUnique: true, minPlayers: 6, notes: "Learn if a player is a werewolf", emoji: "🔮"),
            Role(id: "doctor", name: "Doctor", alignment: "Villager", abilities: ["Protect at night"], isUnique: true, minPlayers: 8, notes: "Save a player from werewolf attack", emoji: "💊"),
            Role(id: "hunter", name: "Hunter", alignment: "Villager", abilities: ["Kill when eliminated"], isUnique: true, minPlayers: 10, notes: "Take revenge when eliminated", emoji: "🏹"),
            Role(id: "jester", name: "Jester", alignment: "Neutral", abilities: ["Win by being voted out"], isUnique: true, minPlayers: 7, notes: "Wins the game by being voted out during the day phase", emoji: "🃏"),
            Role(id: "medium", name: "Medium", alignment: "Villager", abilities: ["Check eliminated players at night"], isUnique: true, minPlayers: 8, notes: "During night, check if an eliminated player was a werewolf or not", emoji: "👻")
        ]
        
        for role in roles {
            modelContext.insert(role)
        }
        
        do {
            try modelContext.save()
            availableRoles = roles
            print("Successfully seeded \(roles.count) roles:")
            for role in roles {
                print("- \(role.name) (\(role.id))")
            }
        } catch {
            print("Error seeding roles: \(error)")
        }
    }
    
    private func seedPresets() {
        let presets = [
            RolePreset(
                id: "beginner_4",
                name: "Beginner (4 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 1),
                    RoleCount(roleID: "villager", count: 3)
                ],
                minPlayers: 4,
                maxPlayers: 4,
                presetDescription: "Minimal setup for learning"
            ),
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
                id: "advanced_10",
                name: "Advanced (10 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 2),
                    RoleCount(roleID: "villager", count: 5),
                    RoleCount(roleID: "seer", count: 1),
                    RoleCount(roleID: "doctor", count: 1),
                    RoleCount(roleID: "jester", count: 1)
                ],
                minPlayers: 10,
                maxPlayers: 10,
                presetDescription: "Con il Matto che può vincere"
            ),
            RolePreset(
                id: "expert_12",
                name: "Expert (12 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 3),
                    RoleCount(roleID: "villager", count: 5),
                    RoleCount(roleID: "seer", count: 1),
                    RoleCount(roleID: "doctor", count: 1),
                    RoleCount(roleID: "hunter", count: 1),
                    RoleCount(roleID: "medium", count: 1)
                ],
                minPlayers: 12,
                maxPlayers: 12,
                presetDescription: "Tutti i ruoli speciali"
            ),
            RolePreset(
                id: "chaos_14",
                name: "Chaos (14 players)",
                roleCounts: [
                    RoleCount(roleID: "werewolf", count: 3),
                    RoleCount(roleID: "villager", count: 6),
                    RoleCount(roleID: "seer", count: 1),
                    RoleCount(roleID: "doctor", count: 1),
                    RoleCount(roleID: "hunter", count: 1),
                    RoleCount(roleID: "medium", count: 1),
                    RoleCount(roleID: "jester", count: 1)
                ],
                minPlayers: 14,
                maxPlayers: 14,
                presetDescription: "Caos totale con tutti i ruoli"
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
    
    private func seedDefaultSettings() {
        let defaultSettings = GameSettings()
        modelContext.insert(defaultSettings)
        gameSettings = defaultSettings
        
        do {
            try modelContext.save()
            print("Default settings created")
        } catch {
            print("Error seeding default settings: \(error)")
        }
    }
    
    func selectPreset(_ preset: RolePreset) {
        selectedPreset = preset
        playerCount = preset.minPlayers
        selectedRoles = preset.roleCounts
        
        // Update includeJester based on whether preset contains Jester
        includeJester = preset.roleCounts.contains { $0.roleID == "jester" }
    }
    
    func updateRoleCount(roleID: String, count: Int) {
        if let index = selectedRoles.firstIndex(where: { $0.roleID == roleID }) {
            selectedRoles[index].count = count
        } else {
            selectedRoles.append(RoleCount(roleID: roleID, count: count))
        }
        
        // Remove zero counts
        selectedRoles.removeAll { $0.count <= 0 }
        
        // Sync includeJester with actual Jester count
        includeJester = selectedRoles.contains { $0.roleID == "jester" && $0.count > 0 }
    }
    
    func getRoleCount(roleID: String) -> Int {
        return selectedRoles.first { $0.roleID == roleID }?.count ?? 0
    }
    
    func getTotalSelectedRoles() -> Int {
        return selectedRoles.reduce(0) { $0 + $1.count }
    }
    
    func isSetupValid() -> Bool {
        let total = getTotalSelectedRoles()
        let werewolfCount = getRoleCount(roleID: "werewolf")
        
        // Basic requirements: total matches player count, minimum 4 players
        guard total == playerCount && total >= 4 else { return false }
        
        // Must have at least 1 werewolf (core requirement for werewolf game)
        guard werewolfCount >= 1 else { return false }
        
        // Werewolves can't be more than half the players (game balance)
        guard werewolfCount < playerCount / 2 + playerCount % 2 else { return false }
        
        return true
    }
    
    func getSetupValidationMessage() -> String? {
        let total = getTotalSelectedRoles()
        let werewolfCount = getRoleCount(roleID: "werewolf")
        
        if total != playerCount {
            let diff = playerCount - total
            if diff > 0 {
                return "Add \(diff) more role\(diff == 1 ? "" : "s")"
            } else {
                return "Remove \(-diff) role\(-diff == 1 ? "" : "s")"
            }
        }
        
        if total < 4 {
            return "Need at least 4 players"
        }
        
        if werewolfCount == 0 {
            return "Must have at least 1 werewolf"
        }
        
        if werewolfCount >= playerCount / 2 + playerCount % 2 {
            let maxWerewolves = playerCount / 2 + playerCount % 2 - 1
            return "Too many werewolves (max \(maxWerewolves) for \(playerCount) players)"
        }
        
        // Check Jester minimum player requirement
        if includeJester && playerCount < 7 {
            return "Jester requires at least 7 players"
        }
        
        return nil
    }
    
    func suggestBalancedSetup() {
        // Clear current selection
        selectedRoles.removeAll()
        
        // Calculate balanced werewolf count (roughly 25-33% of players)
        let werewolfCount = max(1, playerCount / 4)
        
        // Add werewolves
        selectedRoles.append(RoleCount(roleID: "werewolf", count: werewolfCount))
        
        // Calculate remaining villager slots
        var remainingSlots = playerCount - werewolfCount
        
        // Add special roles based on player count
        if playerCount >= 6 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: "seer", count: 1))
            remainingSlots -= 1
        }
        
        if playerCount >= 8 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: "doctor", count: 1))
            remainingSlots -= 1
        }
        
        if playerCount >= 10 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: "hunter", count: 1))
            remainingSlots -= 1
        }
        
        // Add Jester if enabled and we have enough players
        if includeJester && playerCount >= 7 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: "jester", count: 1))
            remainingSlots -= 1
        }
        
        // Fill remaining slots with villagers
        if remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: "villager", count: remainingSlots))
        }
        
        print("Suggested balanced setup for \(playerCount) players:")
        for roleCount in selectedRoles {
            print("- \(roleCount.count)x \(roleCount.roleID)")
        }
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
    
    func getRole(for player: Player) -> Role? {
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
        return session.players.filter { $0.isAlive && $0.roleID != "werewolf" && $0.roleID != "jester" }
    }
    
    func getAllNonWerewolves() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive && $0.roleID != "werewolf" }
    }
    
    func eliminatePlayer(_ player: Player, method: String = "unknown") {
        guard let session = currentSession else { return }
        
        // Add to eliminated players list
        if !session.eliminatedPlayers.contains(player.id) {
            session.eliminatedPlayers.append(player.id)
        }
        
        // Update the player in the session's players array
        if let playerIndex = session.players.firstIndex(where: { $0.id == player.id }) {
            session.players[playerIndex].isAlive = false
        }
        
        // Check if eliminated player is Jester and was voted out
        if player.roleID == "jester" && method == "vote" {
            // Jester wins by being voted out!
            let winEvent = GameEvent(
                id: UUID().uuidString,
                timestamp: Date(),
                type: "jester_win",
                description: "The Jester \(player.displayName) wins the game!",
                playerID: player.id,
                eliminationMethod: method
            )
            session.gameHistory.append(winEvent)
        }
        
        // Add game event
        let event = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "player_eliminated",
            description: "\(player.displayName) was eliminated",
            playerID: player.id,
            eliminationMethod: method
        )
        session.gameHistory.append(event)
        
        // Save the changes
        do {
            try modelContext.save()
            print("Player \(player.displayName) has been eliminated by \(method)")
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
                    eliminatePlayer(targetPlayer, method: "werewolf")
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
    
    func saveEvent(_ event: GameEvent) throws {
        guard var session = currentSession else { return }
        session.gameHistory.append(event)
        currentSession = session
        
        try modelContext.save()
    }
    
    func checkWinCondition() -> String? {
        guard let session = currentSession else { return nil }
        
        // Check for Jester win first (highest priority)
        let jesterWin = session.gameHistory.first { $0.type == "jester_win" }
        if let jesterWin = jesterWin {
            return jesterWin.description
        }
        
        let werewolves = getWerewolves()
        let villagers = getVillagers()
        let allNonWerewolves = getAllNonWerewolves()
        
        if werewolves.isEmpty {
            return "Villagers win! All werewolves have been eliminated."
        }
        
        if werewolves.count >= allNonWerewolves.count {
            return "Werewolves win! They outnumber the remaining players."
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
