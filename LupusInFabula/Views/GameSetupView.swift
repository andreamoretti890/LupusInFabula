//
//  GameSetupView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI

struct GameSetupView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    @State private var showingPresetPicker = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text("Game Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Configure your game")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Player count
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.blue)
                        Text("Number of Players")
                            .font(.headline)
                        Spacer()
                    }
                    
                    HStack {
                        Button(action: { if gameService.playerCount > 4 { gameService.playerCount -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(gameService.playerCount <= 4)
                        
                        Spacer()
                        
                        Text("\(gameService.playerCount)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(minWidth: 80)
                        
                        Spacer()
                        
                        Button(action: { if gameService.playerCount < 24 { gameService.playerCount += 1 } }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .disabled(gameService.playerCount >= 24)
                    }
                    .foregroundStyle(.blue)
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Presets
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(.green)
                        Text("Quick Presets")
                            .font(.headline)
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(gameService.availablePresets, id: \.id) { preset in
                                PresetCard(preset: preset) {
                                    gameService.selectPreset(preset)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Special Role Options
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.purple)
                        Text("Special Roles")
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        Toggle(isOn: Bindable(gameService).includeJester) {
                            HStack(spacing: 12) {
                                Text("🃏")
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text("Include Jester")
                                            .font(.headline)
                                        
                                        Text("JESTER")
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.purple)
                                            .foregroundStyle(.white)
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text("Wins the game by being voted out during the day phase")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                        }
                        .toggleStyle(SwitchToggleStyle())
                        .onChange(of: gameService.includeJester) { _, newValue in
                            // Update role counts when toggle changes
                            if newValue {
                                // Add Jester if not already present
                                if !gameService.selectedRoles.contains(where: { $0.roleID == "jester" }) {
                                    gameService.updateRoleCount(roleID: "jester", count: 1)
                                }
                            } else {
                                // Remove Jester if present
                                gameService.updateRoleCount(roleID: "jester", count: 0)
                            }
                        }
                        
                        if gameService.includeJester && gameService.playerCount < 7 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text("Jester requires at least 7 players")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Role selection
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.badge.key")
                            .foregroundStyle(.orange)
                        Text("Role Selection")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Auto-Balance") {
                            gameService.suggestBalancedSetup()
                        }
                        .buttonStyle(.bordered)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\(gameService.getTotalSelectedRoles())/\(gameService.playerCount)")
                                .font(.subheadline)
                                .foregroundStyle(gameService.isSetupValid() ? .green : .red)
                            
                            if let validationMessage = gameService.getSetupValidationMessage() {
                                Text(validationMessage)
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            } else if gameService.isSetupValid() {
                                Text("Ready to play!")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(gameService.availableRoles.filter { $0.id != "jester" }, id: \.id) { role in
                            RoleSelectionRow(
                                role: role,
                                count: gameService.getRoleCount(roleID: role.id),
                                onCountChanged: { count in
                                    gameService.updateRoleCount(roleID: role.id, count: count)
                                }
                            )
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Start button
                Button {
                    if gameService.isSetupValid() {
                        gameService.startGame()
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(gameService.isSetupValid() ? .blue : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!gameService.isSetupValid())
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Quick Start") {
                    if gameService.isSetupValid() {
                        gameService.startGame()
                        gameService.skipRevealPhase()
                    }
                }
                .disabled(!gameService.isSetupValid())
                .foregroundStyle(.red)
                .font(.caption)
            }
        }
    }
}

struct PresetCard: View {
    let preset: RolePreset
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                Text(preset.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(preset.presetDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                
                Text("\(preset.minPlayers) players")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .frame(width: 140, alignment: .leading)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct RoleSelectionRow: View {
    let role: Role
    let count: Int
    let onCountChanged: (Int) -> Void
    
    var isWerewolf: Bool {
        role.alignment == "Werewolf"
    }
    
    var isSpecialRole: Bool {
        false // No special roles in the regular selection now
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(role.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(role.name)
                        .font(.headline)
                    
                    if isWerewolf {
                        Text("REQUIRED")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                
                Text(role.notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
                
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: { if count > 0 { onCountChanged(count - 1) } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                }
                .disabled(count <= 0)
                
                Text("\(count)")
                    .font(.headline)
                    .frame(minWidth: 20)
                
                Button(action: { onCountChanged(count + 1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            .foregroundStyle(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GameSetupView()
    }
}
