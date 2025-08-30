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
    @State private var showingHunterRevenge = false
    
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
                                Text("day_phase.villagers".localized)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(gameService.getWerewolves().count)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.red)
                                Text("day_phase.werewolves".localized)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Show Jester if present
                            if let session = gameService.currentSession,
                               session.players.contains(where: { $0.isAlive && $0.roleID == RoleID.jester.rawValue }) {
                                VStack(spacing: 8) {
                                    Text("1")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.purple)
                                    Text("Jester".localized)
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // Alive players
                        VStack(spacing: 16) {
                            Text("Alive Players".localized)
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
                    
                    // Action buttons
                    VStack(spacing: 16) {
                        Button(action: startVoting) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("day_phase.start_voting".localized)
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
                                    Text("day_phase.skip_voting".localized)
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
                                Text("day_phase.end_game".localized)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button {
                            gameService.printGameState()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                Text("day_phase.debug".localized)
                            }
                            .font(.caption)
                            .padding()
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("Day Phase ☀️")
        .toolbarTitleDisplayMode(.inline)
        .navigationSubtitle("Round \(gameService.currentSession?.currentRound ?? 1)")
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
        .sheet(isPresented: $showingVoting) {
            VotingView(showingHunterRevenge: $showingHunterRevenge)
        }
        .sheet(isPresented: $showingGameEnd) {
            GameEndView(message: winMessage ?? "Game ended")
        }
        .sheet(isPresented: Bindable(gameService).showingAutoGameEnd) {
            GameEndView(message: gameService.autoGameEndMessage ?? "Game ended")
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
    
    private func checkForHunterRevenge() {
        if gameService.hasPendingHunterRevenge() {
            showingHunterRevenge = true
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

#Preview {
    let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    NavigationStack {
        DayPhaseView()
            .environment(gameService)
    }
}
