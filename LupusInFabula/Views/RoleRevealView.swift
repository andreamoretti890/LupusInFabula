//
//  RoleRevealView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftData
import SwiftUI

struct RoleRevealView: View {
    @Environment(GameService.self) private var gameService: GameService
    @State private var isRevealed = false
    @State private var showingNextPlayer = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 16) {
                        if let player = gameService.getCurrentPlayer() {
                            Text("\(player.displayName)")
                                .font(.title2)
                                .bold()
                        } else {
                            Text("role_reveal.no_current_player".localized)
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                        
                        Text(String(format: "role_reveal.player_progress".localized, gameService.currentRevealPlayerIndex + 1, gameService.currentSession?.players.count ?? 0))
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top)
                    
                    Spacer()
                    
                    // Role card
                    if let _ = gameService.getCurrentPlayer(),
                       let role = gameService.getCurrentPlayerRole() {
                        RoleCard(
                            role: role,
                            isRevealed: isRevealed,
                            onReveal: {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    isRevealed = true
                                }
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                            }
                        )
                        .frame(maxWidth: 300, maxHeight: 400)
                    } else {
                        // Debug info
                        VStack(spacing: 16) {
                            Text("role_reveal.debug_info".localized)
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            Text(String(format: "role_reveal.current_session".localized, gameService.currentSession != nil ? "Exists" : "Nil"))
                                .font(.caption)
                            
                            Text(String(format: "role_reveal.current_player_index".localized, gameService.currentRevealPlayerIndex))
                                .font(.caption)
                            
                            if let session = gameService.currentSession {
                                Text(String(format: "role_reveal.session_players".localized, session.players.count))
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Spacer()
                    
                    // Instructions
                    VStack(spacing: 16) {
                        if !isRevealed {
                            VStack(spacing: 8) {
                                Image(systemName: "hand.tap.fill")
                                    .font(.title)
                                    .foregroundStyle(.blue)
                                
                                Text("role_reveal.tap_hold_reveal".localized)
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.green)
                                
                                Text("role_reveal.role_revealed".localized)
                                    .font(.headline)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
        }
        .navigationTitle("Role Reveal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip All") {
                    gameService.skipRevealPhase()
                }
                .foregroundStyle(.red)
                .font(.caption)
            }
            if isRevealed {
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Button("Next Player") {
                        nextPlayer()
                    }
                }
            }
        }
        .onAppear {
            isRevealed = false
            print("RoleRevealView appeared")
            print("Current session: \(gameService.currentSession != nil ? "exists" : "nil")")
            if let session = gameService.currentSession {
                print("Session players: \(session.players.count)")
                print("Current player index: \(gameService.currentRevealPlayerIndex)")
            }
        }
        .sheet(isPresented: $showingNextPlayer) {
            NextPlayerView()
        }
    }
    
    private func nextPlayer() {
        gameService.nextPlayer()
        
        // Check if we've completed all reveals
        if gameService.currentRevealPlayerIndex == 0 && gameService.currentSession?.currentPhase == "night" {
            // All players have seen their roles, start the game
            showingNextPlayer = true
        } else {
            // Reset for next player
            isRevealed = false
        }
    }
}

struct RoleCard: View {
    let role: Role
    let isRevealed: Bool
    let onReveal: () -> Void
    
    @State private var isPressing = false
    
    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(radius: 10)
                .scaleEffect(isPressing ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressing)
            
            VStack(spacing: 24) {
                if isRevealed {
                    // Role emoji
                    Text(role.emoji)
                        .font(.system(size: 80))
                        .transition(.scale.combined(with: .opacity))
                    
                    // Role name
                    Text(role.name.localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .transition(.opacity)
                    
                    // Role description
                    VStack(spacing: 12) {
                        Text(role.alignment.localized)
                            .font(.headline)
                            .foregroundStyle(role.roleAlignment.color)
                            .transition(.opacity)
                        
                        Text(role.notes.localized)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                } else {
                    // Hidden content - show placeholder
                    VStack(spacing: 24) {
                        // Placeholder emoji
                        Text("❓")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)
                        
                        // Placeholder text
                        VStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.secondary.opacity(0.3))
                                .frame(width: 160, height: 32)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.secondary.opacity(0.2))
                                .frame(width: 100, height: 20)
                            
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.secondary.opacity(0.2))
                                    .frame(width: 200, height: 16)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.secondary.opacity(0.2))
                                    .frame(width: 180, height: 16)
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .padding(32)
            
            // Press indicator
            if isPressing && !isRevealed {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("role_reveal.hold_reveal".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .padding(.bottom, 16)
                }
            }
        }
        .gesture(
            LongPressGesture(minimumDuration: 1.0, maximumDistance: 50)
                .onChanged { _ in
                    if !isRevealed {
                        isPressing = true
                    }
                }
                .onEnded { _ in
                    isPressing = false
                    if !isRevealed {
                        onReveal()
                    }
                }
        )
        .disabled(isRevealed)
    }
}

struct NextPlayerView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            VStack(spacing: 16) {
                                        Text("role_reveal.all_roles_revealed".localized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                                        Text("role_reveal.game_beginning".localized)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Begin Night Phase") {
                gameService.navigateToNight()
                dismiss()
            }
            .fontWeight(.semibold)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
    }
}

#Preview {
    RoleRevealView()
}
