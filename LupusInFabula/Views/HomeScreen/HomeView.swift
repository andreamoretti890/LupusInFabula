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
                    
                    Text("game.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("game.subtitle".localized)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Action buttons
                VStack(spacing: 16) {
                    Button {
                        gameService.navigateToSetup()
                    } label: {
                        Label("button.start_new_game", systemImage: "play.fill")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    if let _ = gameService.lastSavedConfig {
                        Button(action: continueLastGame) {
                            Label("button.continue_last_game", systemImage: "arrow.clockwise")
                                .fontWeight(.semibold)
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
                    Text("how_to_play.title".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        GameRuleRow(icon: "moon.fill", title: String(localized: "game_rule.night_phase.title"), description: String(localized: "game_rule.night_phase.description"))
                        GameRuleRow(icon: "sun.max.fill", title: String(localized: "game_rule.day_phase.title"), description: String(localized: "game_rule.day_phase.description"))
                        GameRuleRow(icon: "person.2.fill", title: String(localized: "game_rule.win_conditions.title"), description: String(localized: "game_rule.win_conditions.description"))
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
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.orange)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingPrivacy = true
                } label: {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.blue)
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
    let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self, FrequentPlayer.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    NavigationStack {
        HomeView()
            .environment(gameService)
            .environment(\.locale, Locale(identifier: "it_IT"))
    }
}
