//
//  NightPhaseView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftData
import SwiftUI

struct NightPhaseView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var currentActionIndex = 0
    @State private var showingHunterRevenge = false
    
    private var nightActions: [NightAction] {
        guard let session = gameService.currentSession else { return [] }
        
        var actions: [NightAction] = []
        
        // Werewolves go first
        let werewolves = session.players.filter { $0.isAlive && $0.roleID == RoleID.werewolf.rawValue }
        if !werewolves.isEmpty {
            actions.append(NightAction(
                type: .werewolf,
                title: "Werewolves".localized,
                description: "night.action.werewolf.description".localized,
                players: werewolves,
                targetPlayers: gameService.getAllNonWerewolves()
            ))
        }
        
        // Seer action
        if let seer = session.players.first(where: { $0.isAlive && $0.roleID == RoleID.seer.rawValue }) {
            actions.append(NightAction(
                type: .seer,
                title: "Seer".localized,
                description: "night.action.seer.description".localized,
                players: [seer],
                targetPlayers: session.players.filter { $0.isAlive && $0.id != seer.id }
            ))
        }
        
        // Doctor action
        if let doctor = session.players.first(where: { $0.isAlive && $0.roleID == RoleID.doctor.rawValue }) {
            var doctorDescription = "night.action.doctor.description".localized
            
            // If werewolf has already targeted someone, show it to the doctor
            if let werewolfTargetID = session.werewolfTarget,
               let targetedPlayer = session.players.first(where: { $0.id == werewolfTargetID }) {
                doctorDescription = "night.action.doctor.werewolf_targeted".localized(targetedPlayer.displayName)
            }
            
            // Get valid targets based on house rules
            let validTargets = gameService.getDoctorValidTargets()
            
            actions.append(NightAction(
                type: .doctor,
                title: "Doctor".localized,
                description: doctorDescription,
                players: [doctor],
                targetPlayers: validTargets
            ))
        }
        
        // Medium action
        if let medium = session.players.first(where: { $0.isAlive && $0.roleID == RoleID.medium.rawValue }) {
            let eliminatedPlayers = session.players.filter { !$0.isAlive }
            
            if !eliminatedPlayers.isEmpty {
                actions.append(NightAction(
                    type: .medium,
                    title: "Medium".localized,
                    description: "night.action.medium.description".localized,
                    players: [medium],
                    targetPlayers: eliminatedPlayers
                ))
            }
        }
        
        return actions
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [.black.opacity(0.8), .blue.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Phase Timer
                    if let settings = gameService.gameSettings, settings.phaseTimer > 0 {
                        PhaseTimerView(totalSeconds: settings.phaseTimer) {
                            // Auto-advance when timer expires
                            handleTimerExpired()
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    if currentActionIndex < nightActions.count {
                        let action = nightActions[currentActionIndex]
                        NightActionView(
                            action: action,
                            allowSkip: shouldAllowSkip(for: action),
                            onComplete: { targetPlayer in
                                completeAction(action: action, targetPlayer: targetPlayer)
                            }
                        )
                    } else {
                        // All actions completed
                        VStack(spacing: 24) {
                            Image(systemName: "sun.max.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(.orange)
                            
                            Text("night.complete")
                                .lineLimit(1)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("night.complete_description")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Begin Day Phase") {
                                gameService.navigateToDay()
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .fontWeight(.semibold)
                        }
                        .padding(40)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("night.title")
        .toolbarTitleDisplayMode(.inline)
        .navigationSubtitle(String(localized: "night.round_subtitle \(gameService.currentSession?.currentRound ?? 1)"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Restart") {
                    gameService.quickRestartGame()
                }
                .foregroundStyle(.orange)
                .font(.caption)
            }
        }
        .onAppear {
            checkForHunterRevenge()
        }
        .sheet(isPresented: $showingHunterRevenge) {
            if let hunter = gameService.getPendingHunter() {
                HunterRevengeView(hunter: hunter)
            }
        }
        .sheet(isPresented: Bindable(gameService).showingAutoGameEnd) {
            GameEndView(message: gameService.autoGameEndMessage ?? "Game ended")
        }
    }
    
    private func completeAction(action: NightAction, targetPlayer: Player?) {
        // Process the action based on type
        switch action.type {
        case .werewolf:
            if let target = targetPlayer {
                // Set werewolf target (don't eliminate yet)
                gameService.setWerewolfTarget(target)
            }
        case .seer:
            if let target = targetPlayer {
                // Show seer result (in a real implementation, this would be shown to the seer)
                showSeerResult(target)
            }
        case .doctor:
            if let target = targetPlayer {
                // Set doctor protection
                gameService.setDoctorProtection(target)
            }
        case .medium:
            if let target = targetPlayer {
                // Show medium result
                showMediumResult(target)
            }
        case .hunter:
            // Hunter revenge is handled immediately when hunter is eliminated
            // This case shouldn't normally occur during night actions
            break
        }
        
        // Move to next action
        currentActionIndex += 1
        
        // If all actions are complete, resolve the night
        if currentActionIndex >= nightActions.count {
            resolveNightPhase()
        }
    }
    
    private func resolveNightPhase() {
        // Resolve all night actions (werewolf attack vs doctor protection)
        gameService.resolveNightActions()
        
        // Check for Hunter revenge after werewolf attack
        if gameService.hasPendingHunterRevenge() {
            // Show Hunter revenge immediately
            showingHunterRevenge = true
        }
    }
    
    private func showSeerResult(_ player: Player) {
        // In a real implementation, this would show the seer the player's alignment
        let isWerewolf = player.roleID == RoleID.werewolf.rawValue
        print("Seer learned that \(player.displayName) is \(isWerewolf ? "a werewolf" : "a villager")")
    }
    
    private func showMediumResult(_ player: Player) {
        guard let _ = gameService.currentSession else { return }
        
        let isWerewolf = player.roleID == RoleID.werewolf.rawValue
        let resultMessage = "\(player.displayName) \(isWerewolf ? "was a werewolf" : "was not a werewolf")"
        
        // Add game event for medium check
        let event = GameEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            type: "medium_check",
            description: "Medium checked \(player.displayName): \(resultMessage)",
            targetPlayerID: player.id
        )
        
        print("Medium learned that \(resultMessage)")
        
        // Save the event
        do {
            try gameService.saveEvent(event)
        } catch {
            print("Error saving medium check: \(error)")
        }
    }
    
    private func shouldAllowSkip(for action: NightAction) -> Bool {
        guard let settings = gameService.gameSettings else { return false }
        
        switch action.type {
        case .werewolf:
            return settings.allowSkipWerewolfKill
        case .seer, .doctor, .medium, .hunter:
            return false // Only werewolf kill can be skipped based on settings
        }
    }
    
    private func handleTimerExpired() {
        // Auto-advance to next action or complete phase when timer expires
        if currentActionIndex < nightActions.count {
            // Skip current action
            currentActionIndex += 1
            
            // If all actions are complete, resolve the night
            if currentActionIndex >= nightActions.count {
                resolveNightPhase()
            }
        }
    }
    
    private func checkForHunterRevenge() {
        if gameService.hasPendingHunterRevenge() {
            showingHunterRevenge = true
        }
    }
}

struct NightAction {
    let type: NightActionType
    let title: String
    let description: String
    let players: [Player]
    let targetPlayers: [Player]
}

struct NightActionView: View {
    @Environment(GameService.self) private var gameService: GameService
    let action: NightAction
    let allowSkip: Bool
    let onComplete: (Player?) -> Void
    
    @State private var selectedTarget: Player? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            // Action header
            VStack(spacing: 12) {
                Text(action.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(action.description)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Player info
            VStack(spacing: 8) {
                Text(action.players.count == 1 ? "night.current_player_singular" : "night.current_player_plural")
                    .font(.headline)
                
                ForEach(action.players, id: \.id) { player in
                    HStack {
                        if let role = gameService.getRole(for: player) {
                            Text(role.emoji)
                                .font(.title2)
                        } else {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.blue)
                        }
                        Text(player.displayName)
                            .font(.title3)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Target selection
            VStack(spacing: 16) {
                Text(localized: "Select Target:")
                    .font(.headline)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(action.targetPlayers, id: \.id) { player in
                            PlayerSelectionCard(
                                player: player,
                                isSelected: selectedTarget?.id == player.id,
                                onSelect: { selectedTarget = player }
                            )
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
            
            // Action buttons
            HStack(spacing: 16) {
                if allowSkip {
                    Button("Skip Phase") {
                        onComplete(nil)
                        selectedTarget = nil
                    }
                    .buttonStyle(.bordered)
                    .foregroundStyle(.orange)
                }
//                else {
//                    Button("Skip") {
//                        onComplete(nil)
//                    }
//                    .buttonStyle(.bordered)
//                }
                
                Button("Confirm") {
                    onComplete(selectedTarget)
                    selectedTarget = nil
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedTarget == nil)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PlayerSelectionCard: View {
    @Environment(GameService.self) private var gameService: GameService
    let player: Player
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                if let role = gameService.getRole(for: player) {
                    Text(role.emoji)
                        .font(.title)
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundStyle(isSelected ? .blue : .secondary)
                }
                
                Text(player.displayName)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? .blue.opacity(0.1) : .clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    NavigationStack {
        NightPhaseView()
            .environment(gameService)
    }
}
