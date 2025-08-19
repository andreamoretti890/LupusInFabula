//
//  NightPhaseView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI

struct NightPhaseView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var currentActionIndex = 0
    @State private var showingDayPhase = false
    
    private var nightActions: [NightAction] {
        guard let session = gameService.currentSession else { return [] }
        
        var actions: [NightAction] = []
        
        // Werewolves go first
        let werewolves = session.players.filter { $0.isAlive && $0.roleID == "werewolf" }
        if !werewolves.isEmpty {
            actions.append(NightAction(
                type: .werewolf,
                title: "Werewolves",
                description: "Choose a villager to eliminate",
                players: werewolves,
                targetPlayers: gameService.getVillagers()
            ))
        }
        
        // Seer action
        if let seer = session.players.first(where: { $0.isAlive && $0.roleID == "seer" }) {
            actions.append(NightAction(
                type: .seer,
                title: "Seer",
                description: "Check if a player is a werewolf",
                players: [seer],
                targetPlayers: session.players.filter { $0.isAlive && $0.id != seer.id }
            ))
        }
        
        // Doctor action
        if let doctor = session.players.first(where: { $0.isAlive && $0.roleID == "doctor" }) {
            var doctorDescription = "Choose a player to protect"
            
            // If werewolf has already targeted someone, show it to the doctor
            if let werewolfTargetID = session.werewolfTarget,
               let targetedPlayer = session.players.first(where: { $0.id == werewolfTargetID }) {
                doctorDescription = "The werewolves targeted \(targetedPlayer.displayName). Choose a player to protect"
            }
            
            actions.append(NightAction(
                type: .doctor,
                title: "Doctor",
                description: doctorDescription,
                players: [doctor],
                targetPlayers: session.players.filter { $0.isAlive }
            ))
        }
        
        return actions
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [.black.opacity(0.8), .blue.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .font(.title)
                                .foregroundStyle(.yellow)
                            Text("Night Phase")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Round \(gameService.currentSession?.currentRound ?? 1)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    if currentActionIndex < nightActions.count {
                        let action = nightActions[currentActionIndex]
                        NightActionView(
                            action: action,
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
                            
                            Text("Night Complete")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("All night actions have been taken. The sun rises...")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            NavigationLink(value: GamePhase.day) {
                                Text("Begin Day Phase")
                                    .fontWeight(.semibold)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                        .padding(40)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            // Development restart button
            Button(action: {
                gameService.quickRestartGame()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                    Text("Restart")
                }
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.orange.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 50)
            .padding(.leading, 20)
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
        
        // Show day phase after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingDayPhase = true
        }
    }
    
    private func showSeerResult(_ player: Player) {
        // In a real implementation, this would show the seer the player's alignment
        let isWerewolf = player.roleID == "werewolf"
        print("Seer learned that \(player.displayName) is \(isWerewolf ? "a werewolf" : "a villager")")
    }
}

struct NightAction {
    let type: ActionType
    let title: String
    let description: String
    let players: [Player]
    let targetPlayers: [Player]
    
    enum ActionType {
        case werewolf
        case seer
        case doctor
    }
}

struct NightActionView: View {
    let action: NightAction
    let onComplete: (Player?) -> Void
    
    @State private var selectedTarget: Player?
    
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
                Text("Current Player:")
                    .font(.headline)
                
                ForEach(action.players, id: \.id) { player in
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.blue)
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
                Text("Select Target:")
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
                Button("Skip") {
                    onComplete(nil)
                }
                .buttonStyle(.bordered)
                
                Button("Confirm") {
                    onComplete(selectedTarget)
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
    let player: Player
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundStyle(isSelected ? .blue : .secondary)
                
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
    NightPhaseView()
}
