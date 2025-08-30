//
//  HunterRevengeView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI
import SwiftData

struct HunterRevengeView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    
    let hunter: Player
    @State private var selectedTarget: Player?
    @State private var showingConfirmation = false
    
    private var availableTargets: [Player] {
        return gameService.getAvailableHunterTargets()
    }
    
    private var canSkipRevenge: Bool {
        return gameService.canSkipHunterRevenge()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark background overlay
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "target")
                                .font(.system(size: 80))
                                .foregroundStyle(.red)
                            
                            Text("hunter_revenge.title".localized)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(canSkipRevenge ? 
                                "\(hunter.displayName) was eliminated!\nChoose a player to take with you, or skip revenge." :
                                "\(hunter.displayName) was eliminated!\nYou must choose a player to take with you.")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Target selection
                        VStack(spacing: 20) {
                            Text("hunter_revenge.choose_target".localized)
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                                ForEach(availableTargets, id: \.id) { player in
                                    PlayerTargetCard(
                                        player: player,
                                        isSelected: selectedTarget?.id == player.id
                                    ) {
                                        selectedTarget = player
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Action buttons
                        VStack(spacing: 16) {
                            if canSkipRevenge {
                                Button("Skip Revenge") {
                                    // Hunter chooses not to use revenge
                                    gameService.currentSession?.pendingHunterRevenge = nil
                                    dismiss()
                                    continueToNextPhase()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.gray)
                            }
                            
                            Button(canSkipRevenge ? "Take Revenge" : "Choose Target to Eliminate") {
                                showingConfirmation = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .disabled(selectedTarget == nil)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 60) // Extra bottom padding for safe area
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .alert("Confirm Revenge", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Eliminate", role: .destructive) {
                if let target = selectedTarget {
                    gameService.executeHunterRevenge(hunterID: hunter.id, targetID: target.id)
                    dismiss()
                    continueToNextPhase()
                }
            }
        } message: {
            if let target = selectedTarget {
                Text(String(format: "hunter_revenge.confirm_elimination".localized, target.displayName))
            }
        }
    }
    
    private func continueToNextPhase() {
        // Determine what phase to go to next based on current game state
        guard let session = gameService.currentSession else { return }
        
        if session.currentPhase == "night" {
            // If we're in night phase, continue to day
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameService.navigateToDay()
            }
        } else if session.currentPhase == "day" {
            // If we're in day phase, continue to night
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gameService.navigateToNight()
            }
        }
    }
}

struct PlayerTargetCard: View {
    let player: Player
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Player icon/emoji based on role
                if let role = gameService.getRole(for: player) {
                    Text(role.emoji)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                }
                
                Text(player.displayName)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .background(isSelected ? .red.opacity(0.3) : .white.opacity(0.1))
            .foregroundStyle(isSelected ? .red : .white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .red : .white.opacity(0.3), lineWidth: 2)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    @Environment(GameService.self) private var gameService: GameService
}

#Preview {
    HunterRevengeView(
        hunter: Player(id: "1", displayName: "Hunter Player", roleID: "hunter")
    )
    .environment(GameService(modelContext: ModelContext(try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self))))
}
