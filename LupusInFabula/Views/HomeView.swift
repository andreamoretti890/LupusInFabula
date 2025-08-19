//
//  HomeView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var showingPrivacy = false
    @State private var showingSettings = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                    
                    Text("Lupus in Fabula")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("The classic party game of deception and deduction")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        gameService.navigateToSetup()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start New Game")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let lastConfig = gameService.lastSavedConfig {
                        Button(action: continueLastGame) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Continue Last Game")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Game info
                VStack(spacing: 16) {
                    Text("How to Play")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        GameRuleRow(icon: "moon.fill", title: "Night Phase", description: "Werewolves choose victims, special roles use abilities")
                        GameRuleRow(icon: "sun.max.fill", title: "Day Phase", description: "Villagers discuss and vote to eliminate suspects")
                        GameRuleRow(icon: "person.2.fill", title: "Win Conditions", description: "Villagers eliminate all werewolves, or werewolves outnumber villagers")
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.orange)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Privacy") {
                    showingPrivacy = true
                }
            }
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    private func continueLastGame() {
        // Load last configuration and start game
        if let lastConfig = gameService.lastSavedConfig {
            gameService.playerCount = lastConfig.playersCount
            gameService.selectedRoles = lastConfig.roleSelection
            gameService.startGame()
        }
    }
}

struct GameRuleRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    NavigationStack {
        HomeView()
            .environment(gameService)
    }
}
