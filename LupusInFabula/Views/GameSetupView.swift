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
    @State private var showingRevealModeSelection = false
    
    private var configuredPlayersCount: Int {
        gameService.playerNames.prefix(gameService.playerCount)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // Player count section with enhanced design
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "person.3.fill")
//                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("setup.number_of_players".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text(String(format: "setup.player_count_range".localized, GameSettings.minPlayers, GameSettings.maxPlayers))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        Text("\(GameSettings.minPlayers)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Slider(value: Binding(
                            get: { Double(gameService.playerCount) },
                            set: { gameService.playerCount = Int($0) }
                        ), in: GameSettings.playersRange, step: 1)
                        .tint(.orange)
                        
                        Text("\(GameSettings.maxPlayers)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        // Large, prominent number display
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.orange.opacity(0.15))
                                .frame(width: 50, height: 36)
                            
                            Text("\(gameService.playerCount)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 0.5)
                )
                
                // Enhanced presets section
//                VStack(spacing: 20) {
//                    HStack(spacing: 12) {
//                        ZStack {
//                            Circle()
//                                .fill(.green.opacity(0.15))
//                                .frame(width: 40, height: 40)
//                            Image(systemName: "list.bullet.rectangle.fill")
//                                .font(.system(size: 18, weight: .semibold))
//                                .foregroundStyle(.green)
//                        }
//                        
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("Quick Presets")
//                                .font(.headline)
//                                .fontWeight(.semibold)
//                            Text("Pre-configured role combinations")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                        
//                        Spacer()
//                        
//                        Text("\(gameService.availablePresets.count) available")
//                            .font(.caption)
//                            .fontWeight(.medium)
//                            .foregroundStyle(.secondary)
//                    }
//                    
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 12) {
//                            ForEach(gameService.availablePresets, id: \.id) { preset in
//                                EnhancedPresetCard(preset: preset) {
//                                    gameService.selectPreset(preset)
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 4)
//                    }
//                }
//                .padding(20)
//                .background(.ultraThinMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(.quaternary, lineWidth: 0.5)
//                )
                
                // Player management card - Enhanced with Apple's latest design guidelines
                VStack(spacing: 20) {
                    // Header with status indicator
                    HStack(spacing: 12) {
                        Image(systemName: "person.text.rectangle.fill")
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("setup.players.title".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("setup.players.description".localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Status badge
                        HStack(spacing: 4) {
                            Image(systemName: configuredPlayersCount == gameService.playerCount ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(configuredPlayersCount == gameService.playerCount ? .green : .orange)
                            
                            Text("\(configuredPlayersCount)/\(gameService.playerCount)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(configuredPlayersCount == gameService.playerCount ? .green : .orange)
                        }
                    }
                    
                    // Player preview section
                    if configuredPlayersCount > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("setup.players.configured".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(0..<gameService.playerCount, id: \.self) { index in
                                        let playerName = gameService.playerNames.indices.contains(index) ? gameService.playerNames[index] : ""
                                        
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(playerName.isEmpty ? .gray.opacity(0.3) : .blue.opacity(0.8))
                                                .frame(width: 8, height: 8)
                                            
                                            Text(playerName.isEmpty ? "player.name_format".localized(index + 1) : playerName)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundStyle(playerName.isEmpty ? .secondary : .primary)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(playerName.isEmpty ? .gray.opacity(0.1) : .blue.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                    }
                    
                    // Action buttons with modern design
                    Button {
                        showingManagePlayers = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14))
                            Text("setup.add_names".localized)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.green.opacity(0.1))
                        .foregroundStyle(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.quaternary, lineWidth: 0.5)
                )

                // Role selection
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "person.badge.key")
                            .foregroundStyle(.orange)
                        Text("setup.role_selection".localized)
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
                                                    /// Automatically decrease the number of villagers if another good role is selected
                                                    /// and the amount of selected roles is equal or exceeds the player count
                                                    if role.roleID != .villager,
                                                       role.roleAlignment == .villager,
                                                       gameService.getTotalSelectedRoles() >= gameService.playerCount,
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
                        Text("setup.special_roles".localized)
                            .font(.headline)
                        Spacer()
                    }
                    
                    VStack(spacing: 12) {
                        Toggle(isOn: Bindable(gameService).includeJester) {
                            HStack(spacing: 12) {
                                Text("🃏")
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Jester".localized)
                                        .font(.headline)
                                    
                                    Text("setup.jester.description".localized)
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
                                Text("setup.jester.requirement".localized)
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
                
                // Enhanced start button with better visual feedback
                VStack(spacing: 16) {
                    if !gameService.isSetupValid() {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("setup.complete_setup".localized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    
                    Button {
                        // Action handled by tap gesture below
                        if gameService.isSetupValid() {
                            showingRevealModeSelection = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            if gameService.isSetupValid() {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            } else {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Text(gameService.isSetupValid() ? "Start Game" : "Complete Setup")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(gameService.isSetupValid() ? .blue : .gray.opacity(0.3))
                        )
                        .foregroundStyle(gameService.isSetupValid() ? .white : .secondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(gameService.isSetupValid() ? .clear : .gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!gameService.isSetupValid())
                    .scaleEffect(gameService.isSetupValid() ? 1.0 : 0.98)
                    .animation(.easeInOut(duration: 0.2), value: gameService.isSetupValid())
//                    .onTapGesture {
//                        if gameService.isSetupValid() {
//                            showingRevealModeSelection = true
//                        }
//                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, 50)
        }
        .navigationTitle("setup.title")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitle("setup.subtitle")
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    dismiss()
                }
            }
            #if DEBUG
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
            #endif
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if gameService.isSetupValid() {
                        gameService.startGame()
                    }
                } label: {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.blue)
                }
                .disabled(!gameService.isSetupValid())
            }
        }
        .sheet(isPresented: $showingManagePlayers) {
            NavigationStack {
                ManagePlayersView()
            }
            .environment(gameService)
        }
        .sheet(isPresented: $showingRevealModeSelection) {
            RevealModeSelectionView()
        }
    }
}

struct EnhancedPresetCard: View {
    let preset: RolePreset
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header with icon and name
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Text("\(preset.minPlayers)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.green)
                        )
                    
                    Text(preset.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                
                // Description
                Text(preset.presetDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                // Players count badge
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 10))
                        Text(String(format: "preset.players".localized, preset.minPlayers))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                }
            }
            .frame(width: 160, alignment: .leading)
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.quaternary, lineWidth: 0.5)
            )
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
