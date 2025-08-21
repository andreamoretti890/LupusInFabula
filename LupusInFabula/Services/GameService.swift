//
//  GameService.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class GameService {
    private var modelContext: ModelContext
    
    // Game state
    var currentSession: GameSession?
    var availableRoles: [Role] = []
    var availablePresets: [RolePreset] = []
    var lastSavedConfig: SavedConfig?
    var gameSettings: GameSettings?
    var frequentPlayers: [FrequentPlayer] = []
    
    // Setup state
    var playerCount: Int = 8 {
        didSet {
            syncPlayerNamesCount()
        }
    }
    var playerNames: [String] = []
    var selectedRoles: [RoleCount] = []
    var selectedPreset: RolePreset?
    var includeJester: Bool = false
    
    // Reveal state
    var currentRevealPlayerIndex: Int = 0
    var isRevealing: Bool = false
    
    // Navigation state
    var navigationPath = NavigationPath()
    
    // Game end state
    var autoGameEndMessage: String?
    var showingAutoGameEnd: Bool = false
    
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
        let frequentDescriptor = FetchDescriptor<FrequentPlayer>()
        
        do {
            availableRoles = try modelContext.fetch(roleDescriptor)
            availablePresets = try modelContext.fetch(presetDescriptor)
            let configs = try modelContext.fetch(configDescriptor)
            lastSavedConfig = configs.first
            
            let settings = try modelContext.fetch(settingsDescriptor)
            gameSettings = settings.first
            frequentPlayers = try modelContext.fetch(frequentDescriptor)
            
            print("Loaded \(availableRoles.count) roles from database:")
            for role in availableRoles {
                print("- \(role.name) (\(role.id))")
            }
        } catch {
            print("Error loading data: \(error)")
        }
        
        // Seed data if empty or force refresh if we have missing roles
        let expectedRoleIds = RoleID.allCases.map { $0.rawValue }
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

        // Ensure player names array matches current player count
        syncPlayerNamesCount()
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
        // Create roles using enums for type safety
        let roles = RoleID.allCases.map { roleID in
            Role(roleID: roleID)
        }
        
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
                    RoleCount(roleID: .werewolf, count: 1),
                    RoleCount(roleID: .villager, count: 3)
                ],
                minPlayers: 4,
                maxPlayers: 4,
                presetDescription: "Minimal setup for learning"
            ),
            RolePreset(
                id: "classic_6",
                name: "Classic (6 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 2),
                    RoleCount(roleID: .villager, count: 3),
                    RoleCount(roleID: .seer, count: 1)
                ],
                minPlayers: 6,
                maxPlayers: 6,
                presetDescription: "Perfect for beginners"
            ),
            RolePreset(
                id: "classic_8",
                name: "Classic (8 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 2),
                    RoleCount(roleID: .villager, count: 4),
                    RoleCount(roleID: .seer, count: 1),
                    RoleCount(roleID: .doctor, count: 1)
                ],
                minPlayers: 8,
                maxPlayers: 8,
                presetDescription: "Balanced gameplay"
            ),
            RolePreset(
                id: "advanced_10",
                name: "Advanced (10 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 2),
                    RoleCount(roleID: .villager, count: 5),
                    RoleCount(roleID: .seer, count: 1),
                    RoleCount(roleID: .doctor, count: 1),
                    RoleCount(roleID: .jester, count: 1)
                ],
                minPlayers: 10,
                maxPlayers: 10,
                presetDescription: "With the Jester who can win"
            ),
            RolePreset(
                id: "expert_12",
                name: "Expert (12 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 3),
                    RoleCount(roleID: .villager, count: 5),
                    RoleCount(roleID: .seer, count: 1),
                    RoleCount(roleID: .doctor, count: 1),
                    RoleCount(roleID: .hunter, count: 1),
                    RoleCount(roleID: .medium, count: 1)
                ],
                minPlayers: 12,
                maxPlayers: 12,
                presetDescription: "All special roles"
            ),
            RolePreset(
                id: "mayor_10",
                name: "Mayor's Village (10 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 2),
                    RoleCount(roleID: .villager, count: 5),
                    RoleCount(roleID: .seer, count: 1),
                    RoleCount(roleID: .doctor, count: 1),
                    RoleCount(roleID: .mayor, count: 1)
                ],
                minPlayers: 10,
                maxPlayers: 10,
                presetDescription: "Features the Mayor role for village leadership"
            ),
            RolePreset(
                id: "chaos_14",
                name: "Chaos (14 players)",
                roleCounts: [
                    RoleCount(roleID: .werewolf, count: 3),
                    RoleCount(roleID: .villager, count: 5),
                    RoleCount(roleID: .seer, count: 1),
                    RoleCount(roleID: .doctor, count: 1),
                    RoleCount(roleID: .hunter, count: 1),
                    RoleCount(roleID: .medium, count: 1),
                    RoleCount(roleID: .mayor, count: 1),
                    RoleCount(roleID: .jester, count: 1)
                ],
                minPlayers: 14,
                maxPlayers: 14,
                presetDescription: "Total chaos with all roles including Mayor"
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
        includeJester = preset.roleCounts.contains { $0.roleID == RoleID.jester.rawValue }
    }
    
    func updateRoleCount(roleID: RoleID, count: Int) {
        updateRoleCount(roleID: roleID.rawValue, count: count)
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
        includeJester = selectedRoles.contains { $0.roleID == RoleID.jester.rawValue && $0.count > 0 }
    }
    
    func getRoleCount(roleID: String) -> Int {
        return selectedRoles.first { $0.roleID == roleID }?.count ?? 0
    }
    
    func getRoleCount(roleID: RoleID) -> Int {
        return selectedRoles.first { $0.roleID == roleID.rawValue }?.count ?? 0
    }
    
    func getTotalSelectedRoles() -> Int {
        return selectedRoles.reduce(0) { $0 + $1.count }
    }
    
    func isSetupValid() -> Bool {
        let total = getTotalSelectedRoles()
        let werewolfCount = getRoleCount(roleID: RoleID.werewolf.rawValue)
        
        // Basic requirements: total matches player count, minimum 4 players
        guard total == playerCount && total >= 4 else { return false }
        
        // Must have at least 1 werewolf (core requirement for werewolf game)
        guard werewolfCount >= 1 else { return false }
        
        // Werewolves can't be more than half the players (game balance)
        guard werewolfCount < playerCount / 2 + playerCount % 2 else { return false }
        
        return true
    }
    
    func suggestBalancedSetup() {
        // Clear current selection
        selectedRoles.removeAll()
        
        // Calculate balanced werewolf count (roughly 25-33% of players)
        let werewolfCount = max(1, playerCount / 4)
        
        // Add werewolves
        selectedRoles.append(RoleCount(roleID: .werewolf, count: werewolfCount))
        
        // Calculate remaining villager slots
        var remainingSlots = playerCount - werewolfCount
        
        // Add special roles based on player count
        if playerCount >= 6 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .seer, count: 1))
            remainingSlots -= 1
        }
        
        if playerCount >= 8 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .doctor, count: 1))
            remainingSlots -= 1
        }
        
        if playerCount >= 9 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .mayor, count: 1))
            remainingSlots -= 1
        }
        
        if playerCount >= 10 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .hunter, count: 1))
            remainingSlots -= 1
        }
        
        // Add Jester if enabled and we have enough players
        if includeJester && playerCount >= 7 && remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .jester, count: 1))
            remainingSlots -= 1
        }
        
        // Fill remaining slots with villagers
        if remainingSlots > 0 {
            selectedRoles.append(RoleCount(roleID: .villager, count: remainingSlots))
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
            // Use provided name if available, else fallback to localized default
            let providedName = sanitizedPlayerName(at: i)
            let displayName = providedName.isEmpty ? "player.name_format".localized(i + 1) : providedName
            let player = Player(
                id: UUID().uuidString,
                displayName: displayName,
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
            currentPhase: GamePhase.reveal.rawValue
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
            
            // Record used player names into frequent players
            recordPlayersUsed(names: players.map { $0.displayName })

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
            currentRevealPlayerIndex = 0
            navigateToNight()
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
        
        // Navigate to night phase
        navigateToNight()
        print("Skipped reveal phase - moving to night")
    }
    
    func navigateToSetup() {
        navigationPath.append(GamePhase.setup)
    }
    
    func navigateToNight() {
        guard let session = currentSession else { return }
        
        // Only increment round when transitioning from day to night (not from reveal to night)
        if session.currentPhase == GamePhase.day.rawValue {
            session.currentRound += 1
        }
        session.currentPhase = GamePhase.night.rawValue
        
        do {
            try modelContext.save()
            print("Advanced to night phase - Round \(session.currentRound)")
        } catch {
            print("Error saving night phase transition: \(error)")
        }
        
        navigationPath.append(GamePhase.night)
    }
    
    func navigateToDay() {
        guard let session = currentSession else { return }
        
        // Update phase to day (round stays the same)
        session.currentPhase = GamePhase.day.rawValue
        
        do {
            try modelContext.save()
            print("Advanced to day phase - Round \(session.currentRound)")
        } catch {
            print("Error saving day phase transition: \(error)")
        }
        
        navigationPath.append(GamePhase.day)
    }
    
    func navigateToGameEnd(message: String) {
        // Set the auto game end state to trigger the GameEndView
        autoGameEndMessage = message
        showingAutoGameEnd = true
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
        return session.players.filter { $0.isAlive && $0.roleID == RoleID.werewolf.rawValue }
    }
    
    func getVillagers() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive && $0.roleID != RoleID.werewolf.rawValue && $0.roleID != RoleID.jester.rawValue }
    }
    
    func getAllNonWerewolves() -> [Player] {
        guard let session = currentSession else { return [] }
        return session.players.filter { $0.isAlive && $0.roleID != RoleID.werewolf.rawValue }
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
        
        // Check if eliminated player is Hunter - trigger revenge ability
        if player.roleID == RoleID.hunter.rawValue && method != "hunter" {
            // Hunter was killed, set pending revenge
            session.pendingHunterRevenge = player.id
            print("Hunter \(player.displayName) was eliminated and can take revenge!")
        }
        
        // Check if eliminated player is Jester and was voted out
        if player.roleID == RoleID.jester.rawValue && method == "vote" {
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
        
        // Check for automatic game end after elimination
        checkAndHandleGameEnd()
    }
    
    // MARK: - Hunter Functions
    
    func executeHunterRevenge(hunterID: String, targetID: String) {
        guard let session = currentSession else { return }
        guard session.pendingHunterRevenge == hunterID else { return }
        
        // Find the hunter and target players
        guard let hunter = session.players.first(where: { $0.id == hunterID }),
              let target = session.players.first(where: { $0.id == targetID }) else { return }
        
        // Execute hunter's revenge
        session.hunterTarget = targetID
        eliminatePlayer(target, method: "hunter")
        
        // Clear pending revenge
        session.pendingHunterRevenge = nil
        
        // Add game event for hunter revenge
        let revengeEvent = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "hunter_revenge",
            description: "Hunter \(hunter.displayName) takes revenge on \(target.displayName)",
            playerID: hunterID,
            targetPlayerID: targetID,
            eliminationMethod: "hunter"
        )
        session.gameHistory.append(revengeEvent)
        
        print("Hunter \(hunter.displayName) executed revenge on \(target.displayName)")
        
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error saving hunter revenge: \(error)")
        }
    }
    
    func getAvailableHunterTargets() -> [Player] {
        guard let session = currentSession else { return [] }
        guard session.pendingHunterRevenge != nil else { return [] }
        
        // Hunter can target any living player
        return session.players.filter { $0.isAlive }
    }
    
    func hasPendingHunterRevenge() -> Bool {
        guard let session = currentSession else { return false }
        return session.pendingHunterRevenge != nil
    }
    
    func getPendingHunter() -> Player? {
        guard let session = currentSession,
              let hunterID = session.pendingHunterRevenge else { return nil }
        return session.players.first(where: { $0.id == hunterID })
    }
    
    func canSkipHunterRevenge() -> Bool {
        return gameSettings?.allowSkipHunterRevenge ?? false
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
        
        // Check if doctor is protecting himself and track self-save usage
        if let doctor = session.players.first(where: { $0.isAlive && $0.roleID == RoleID.doctor.rawValue }),
           doctor.id == player.id {
            session.doctorSelfSaveUsed = true
        }
        
        session.doctorProtection = player.id
        session.lastDoctorProtection = player.id
        
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
        // Note: lastDoctorProtection is kept for consecutive saves rule
        
        do {
            try modelContext.save()
            print("Night actions resolved")
        } catch {
            print("Error saving night resolution: \(error)")
        }
    }
    
    func saveEvent(_ event: GameEvent) throws {
        guard let session = currentSession else { return }
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
//        let villagers = getVillagers()
        let allNonWerewolves = getAllNonWerewolves()
        
        if werewolves.isEmpty {
            return "Villagers win! All werewolves have been eliminated."
        }
        
        if werewolves.count >= allNonWerewolves.count {
            return "Werewolves win! They outnumber the remaining players."
        }
        
        return nil
    }
    
    func checkAndHandleGameEnd() {
        // Don't auto-end if there's a pending hunter revenge - wait for that to complete
        if hasPendingHunterRevenge() {
            return
        }
        
        if let winMessage = checkWinCondition() {
            guard let session = currentSession else { return }
            
            // Update session to ended state
            session.currentPhase = "ended"
            
            do {
                try modelContext.save()
                print("Game automatically ended: \(winMessage)")
            } catch {
                print("Error saving game end: \(error)")
            }
            
            // Navigate to game end screen with a slight delay to allow UI updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.navigateToGameEnd(message: winMessage)
            }
        }
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
    
    // MARK: - Doctor Functions
    
    func getDoctorValidTargets() -> [Player] {
        guard let session = currentSession,
              let settings = gameSettings,
              let doctor = session.players.first(where: { $0.isAlive && $0.roleID == RoleID.doctor.rawValue }) else { return [] }
        
        var validTargets = session.players.filter { $0.isAlive }
        
        // Remove doctor from targets if self-save is disabled or already used
        if !settings.doctorCanSaveHimself || session.doctorSelfSaveUsed {
            validTargets.removeAll { $0.id == doctor.id }
        }
        
        // Remove last protected player if consecutive saves are disabled
        if !settings.doctorCanSaveSamePersonTwice,
           let lastProtected = session.lastDoctorProtection {
            validTargets.removeAll { $0.id == lastProtected }
        }
        
        return validTargets
    }
    
    func canDoctorSaveHimself() -> Bool {
        guard let session = currentSession,
              let settings = gameSettings else { return false }
        
        return settings.doctorCanSaveHimself && !session.doctorSelfSaveUsed
    }
    
    func canDoctorSaveSamePersonTwice() -> Bool {
        return gameSettings?.doctorCanSaveSamePersonTwice ?? false
    }
    
    // MARK: - Mayor Functions
    
    func getMayor() -> Player? {
        guard let session = currentSession else { return nil }
        return session.players.first { $0.isAlive && $0.roleID == RoleID.mayor.rawValue }
    }
    
    func isMayorAlive() -> Bool {
        return getMayor() != nil
    }

    // MARK: - Player Names Management
    
    private func syncPlayerNamesCount() {
        if playerNames.count < playerCount {
            playerNames.append(contentsOf: Array(repeating: "", count: playerCount - playerNames.count))
        } else if playerNames.count > playerCount {
            playerNames = Array(playerNames.prefix(playerCount))
        }
    }
    
    private func sanitizedPlayerName(at index: Int) -> String {
        guard index >= 0 && index < playerNames.count else { return "" }
        return playerNames[index].trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func setPlayerName(at index: Int, to newName: String) {
        guard index >= 0 else { return }
        syncPlayerNamesCount()
        if index >= playerNames.count {
            playerNames.append(contentsOf: Array(repeating: "", count: index - playerNames.count + 1))
        }
        playerNames[index] = newName
    }
    
    func getNameSuggestions(prefix: String = "", limit: Int = 6, excluding currentNames: [String] = []) -> [String] {
        let normalizedPrefix = prefix.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let excludeSet = Set(currentNames.map { $0.lowercased() })
        let sorted = frequentPlayers.sorted { a, b in
            if a.playCount == b.playCount {
                return a.lastPlayedAt > b.lastPlayedAt
            }
            return a.playCount > b.playCount
        }
        let filtered = sorted
            .map { $0.displayName }
            .filter { name in
                let lower = name.lowercased()
                let matchesPrefix = normalizedPrefix.isEmpty || lower.hasPrefix(normalizedPrefix)
                let notExcluded = !excludeSet.contains(lower)
                return matchesPrefix && notExcluded
            }
        return Array(LinkedHashSet(filtered)).prefix(limit).map { $0 }
    }
    
    func recordPlayersUsed(names: [String]) {
        let cleaned = names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { !isDefaultPlayerName($0) }
        guard !cleaned.isEmpty else { return }
        var dirty = false
        for name in Set(cleaned.map { $0 }) {
            if let existingIndex = frequentPlayers.firstIndex(where: { $0.displayName.caseInsensitiveCompare(name) == .orderedSame }) {
                frequentPlayers[existingIndex].lastPlayedAt = Date()
                frequentPlayers[existingIndex].playCount += 1
                dirty = true
            } else {
                let fp = FrequentPlayer(displayName: name, lastPlayedAt: Date(), playCount: 1)
                modelContext.insert(fp)
                frequentPlayers.append(fp)
                dirty = true
            }
        }
        if dirty {
            do { try modelContext.save() } catch { print("Error saving frequent players: \(error)") }
        }
    }
    
    private func isDefaultPlayerName(_ name: String) -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Get the localized player name format for the current language
        let localizedFormat = "player.name_format".localized(1) // Use 1 as placeholder
        let baseName = localizedFormat.replacingOccurrences(of: "1", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create a regex pattern that matches the localized format with any number
        let pattern = #"^\#(baseName)\s*\d+$"#
        
        return trimmedName.range(of: pattern, options: .regularExpression) != nil
    }
    
    func deleteFrequentPlayer(name: String) {
        if let index = frequentPlayers.firstIndex(where: { $0.displayName.caseInsensitiveCompare(name) == .orderedSame }) {
            let player = frequentPlayers[index]
            modelContext.delete(player)
            frequentPlayers.remove(at: index)
            do {
                try modelContext.save()
                print("Deleted frequent player: \(name)")
            } catch {
                print("Error deleting frequent player: \(error)")
            }
        }
    }
}

// Small ordered-set helper to maintain insertion order while removing duplicates
fileprivate struct LinkedHashSet<Element: Hashable>: Sequence {
    private var set: Set<Element> = []
    private var order: [Element] = []
    init<S: Sequence>(_ seq: S) where S.Element == Element {
        for e in seq {
            if !set.contains(e) {
                set.insert(e)
                order.append(e)
            }
        }
    }
    func makeIterator() -> IndexingIterator<[Element]> { order.makeIterator() }
}
