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
    @State private var showingManagePlayers = false
    
    private var configuredPlayersCount: Int {
        gameService.playerNames.prefix(gameService.playerCount)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Label("setup.number_of_players", systemImage: "person.3.fill")
                        .foregroundStyle(.orange)
                    
                    HStack {
                        Slider(value: Binding(
                            get: { Double(gameService.playerCount) },
                            set: { gameService.playerCount = Int($0) }
                        ), in: 4...24, step: 1)
                        
                        Text("\(gameService.playerCount)")
                            .foregroundStyle(.secondary)
                            .bold()
                    }
                }
                .padding()
                .tint(.orange)
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
                
                // Player management card
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundStyle(.blue)
                        Text("Players")
                            .font(.headline)
                        Spacer()
                        Text("\(configuredPlayersCount)/\(gameService.playerCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .bold()
                    }
                    
                    HStack {
                        Button {
                            showingManagePlayers = true
                        } label: {
                            Label("Manage Players", systemImage: "square.and.pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
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
                        
                        Text("\(gameService.getTotalSelectedRoles())/\(gameService.playerCount)")
                            .font(.subheadline)
                            .foregroundStyle(gameService.isSetupValid() ? .green : .red)
                            .fixedSize()
                            .bold()
                            .padding(.trailing, 8)
                        
                        Button {
                            gameService.suggestBalancedSetup()
                        } label: {
                            Label("Auto-Balance", systemImage: "sparkles")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.bordered)
                        .foregroundStyle(.orange)
                    }
                    
                    LazyVStack(spacing: 16) {
                        // Group roles by alignment
                        ForEach(RoleAlignment.allCases, id: \.self) { alignment in
                            let rolesForAlignment = gameService.availableRoles.filter { 
                                $0.roleAlignment == alignment && $0.id != RoleID.jester.rawValue 
                            }
                            
                            if !rolesForAlignment.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(alignment.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(alignment.color)
                                    
                                    LazyVStack(spacing: 8) {
                                        ForEach(rolesForAlignment, id: \.id) { role in
                                            RoleSelectionRow(
                                                role: role,
                                                count: gameService.getRoleCount(roleID: role.id),
                                                onCountChanged: { count in
                                                    // Automatically decrease the number of villagers if another good role is selected
                                                    if role.roleID != .villager,
                                                       role.roleAlignment == .villager,
                                                       count > gameService.getRoleCount(roleID: role.roleID) {
                                                        let numberOfVillagers = gameService.getRoleCount(roleID: RoleID.villager)
                                                        gameService.updateRoleCount(roleID: RoleID.villager, count: numberOfVillagers - 1)
                                                    }
                                                    gameService.updateRoleCount(roleID: role.id, count: count)
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                        }
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
                                    Text("Jester")
                                        .font(.headline)
                                    
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
                                if !gameService.selectedRoles.contains(where: { $0.roleID == RoleID.jester.rawValue }) {
                                    gameService.updateRoleCount(roleID: RoleID.jester.rawValue, count: 1)
                                }
                            } else {
                                // Remove Jester if present
                                gameService.updateRoleCount(roleID: RoleID.jester.rawValue, count: 0)
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
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 40)
        }
        .navigationTitle("setup.title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitle("setup.subtitle")
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
        .sheet(isPresented: $showingManagePlayers) {
            NavigationStack {
                ManagePlayersView()
            }
            .environment(gameService)
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

struct RoleRow: View {
    let role: Role
    
    var body: some View {
        Text(role.emoji)
            .font(.title2)
        
        VStack(alignment: .leading, spacing: 4) {
            Text(role.name.localized)
                .font(.headline)
            
            Text(role.notes.localized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
            
        Spacer()
    }
}

struct RoleSelectionRow: View {
    let role: Role
    let count: Int
    let onCountChanged: (Int) -> Void
    
    var isSpecialRole: Bool {
        false // No special roles in the regular selection now
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if role.isUnique {
                Toggle(isOn: .init(get: {
                    count == 1
                }, set: { value in
                    onCountChanged(value ? 1 : 0)
                })) {
                    HStack(spacing: 12) {
                        RoleRow(role: role)
                    }
                }
            } else {
                RoleRow(role: role)
                
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
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GameSetupView()
    }
}
