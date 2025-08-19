//
//  DayPhaseView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftData
import SwiftUI

struct DayPhaseView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var showingVoting = false
    @State private var showingGameEnd = false
    @State private var winMessage: String?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [.orange.opacity(0.3), .yellow.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .font(.title)
                                .foregroundStyle(.orange)
                            Text("Day Phase")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        Text("Round \(gameService.currentSession?.currentRound ?? 1)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Phase Timer
                    if let settings = gameService.gameSettings, settings.phaseTimer > 0 {
                        PhaseTimerView(totalSeconds: settings.phaseTimer) {
                            // Auto-advance when timer expires
                            handleTimerExpired()
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Game status
                    VStack(spacing: 24) {
                        // Player counts
                        HStack(spacing: 30) {
                            VStack(spacing: 8) {
                                Text("\(gameService.getVillagers().count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.green)
                                Text("Villagers")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(gameService.getWerewolves().count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.red)
                                Text("Werewolves")
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Show Jester if present
                            if let session = gameService.currentSession,
                               session.players.contains(where: { $0.isAlive && $0.roleID == "jester" }) {
                                VStack(spacing: 8) {
                                    Text("1")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.purple)
                                    Text("Jester")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // Alive players
                        VStack(spacing: 16) {
                            Text("Alive Players")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 12) {
                                ForEach(gameService.getAlivePlayers(), id: \.id) { player in
                                    PlayerStatusCard(player: player)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: startVoting) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Start Voting")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Skip Voting button (conditional)
                        if let settings = gameService.gameSettings, settings.allowSkipDayVoting {
                            Button(action: skipVoting) {
                                HStack {
                                    Image(systemName: "forward.fill")
                                    Text("Skip Voting Phase")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.orange)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                        Button(action: endGame) {
                            HStack {
                                Image(systemName: "flag.fill")
                                Text("End Game")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            VStack(spacing: 8) {
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
                
                // Debug button
                Button(action: {
                    gameService.printGameState()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "info.circle")
                        Text("Debug")
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.purple.opacity(0.8))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                }
            }
            .padding(.top, 50)
            .padding(.leading, 20)
        }
        .sheet(isPresented: $showingVoting) {
            VotingView()
        }
        .sheet(isPresented: $showingGameEnd) {
            GameEndView(message: winMessage ?? "Game ended")
        }
        .onAppear {
            checkWinCondition()
        }
    }
    
    private func startVoting() {
        showingVoting = true
    }
    
    private func endGame() {
        showingGameEnd = true
    }
    
    private func checkWinCondition() {
        if let message = gameService.checkWinCondition() {
            winMessage = message
            showingGameEnd = true
        }
    }
    
    private func skipVoting() {
        // Skip voting phase and go directly to night
        gameService.navigateToNight()
    }
    
    private func handleTimerExpired() {
        // Auto-skip voting when timer expires if skip is enabled
        if let settings = gameService.gameSettings, settings.allowSkipDayVoting {
            skipVoting()
        } else {
            // Otherwise, just start voting automatically
            startVoting()
        }
    }
}

struct PlayerStatusCard: View {
    @Environment(GameService.self) private var gameService: GameService
    let player: Player
    
    var body: some View {
        VStack(spacing: 8) {
            if let role = gameService.getRole(for: player) {
                Text(role.emoji)
                    .font(.title2)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            
            Text(player.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct VotingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    @State private var selectedPlayer: Player?
    @State private var showingResults = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Vote to Eliminate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Choose a player to eliminate from the village")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Phase Timer for voting
                if let settings = gameService.gameSettings, settings.phaseTimer > 0 {
                    PhaseTimerView(totalSeconds: settings.phaseTimer) {
                        // Auto-submit vote when timer expires
                        handleVotingTimerExpired()
                    }
                    .padding(.horizontal, 24)
                }
                
                // Player selection
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(gameService.getAlivePlayers(), id: \.id) { player in
                            VotingPlayerCard(
                                player: player,
                                isSelected: selectedPlayer?.id == player.id,
                                onSelect: { selectedPlayer = player }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Vote button
                Button(action: submitVote) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Submit Vote")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPlayer != nil ? .blue : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedPlayer == nil)
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingResults) {
            VotingResultsView(eliminatedPlayer: selectedPlayer)
        }
    }
    
    private func submitVote() {
        guard let player = selectedPlayer else { return }
        
        // In a real implementation, this would record the vote
        print("Vote submitted to eliminate \(player.displayName)")
        
        showingResults = true
    }
    
    private func handleVotingTimerExpired() {
        // Auto-submit vote with current selection, or no elimination
        showingResults = true
    }
}

struct VotingPlayerCard: View {
    @Environment(GameService.self) private var gameService: GameService
    let player: Player
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                if let role = gameService.getRole(for: player) {
                    Text(role.emoji)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(isSelected ? .red : .blue)
                }
                
                Text(player.displayName)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .red : .primary)
                
                if isSelected {
                    Text("Selected for elimination")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
//            .background(isSelected ? .red.opacity(0.1) : .regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .red : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct VotingResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    let eliminatedPlayer: Player?
    @State private var hasProcessedElimination = false
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "person.crop.circle.badge.minus")
                .font(.system(size: 80))
                .foregroundStyle(.red)
            
            VStack(spacing: 16) {
                Text("Vote Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let player = eliminatedPlayer {
                    Text("\(player.displayName) has been eliminated from the village.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("No player was eliminated.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button("Continue to Night") {
                if let player = eliminatedPlayer, !hasProcessedElimination {
                    gameService.eliminatePlayer(player, method: "vote")
                    hasProcessedElimination = true
                }
                dismiss()
                gameService.navigateToNight()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
        .onAppear {
            // Process elimination when view appears
            if let player = eliminatedPlayer, !hasProcessedElimination {
                gameService.eliminatePlayer(player, method: "vote")
                hasProcessedElimination = true
            }
        }
    }
}

struct GameEndView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    let message: String
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Back to Home") {
                dismiss()
                gameService.endGameAndReturnHome()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
    }
}

#Preview {
    let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    NavigationStack {
        DayPhaseView()
            .environment(gameService)
    }
}
