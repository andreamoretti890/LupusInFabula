//
//  RoleRevealView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

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
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Role Reveal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let player = gameService.getCurrentPlayer() {
                            Text("\(player.displayName)")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("No current player")
                                .font(.title2)
                                .foregroundStyle(.red)
                        }
                        
                        Text("\(gameService.currentRevealPlayerIndex + 1) of \(gameService.currentSession?.players.count ?? 0)")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Role card
                    if let player = gameService.getCurrentPlayer(),
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
                            Text("Debug Info")
                                .font(.headline)
                                .foregroundStyle(.red)
                            
                            Text("Current Session: \(gameService.currentSession != nil ? "Exists" : "Nil")")
                                .font(.caption)
                            
                            Text("Current Player Index: \(gameService.currentRevealPlayerIndex)")
                                .font(.caption)
                            
                            if let session = gameService.currentSession {
                                Text("Session Players: \(session.players.count)")
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
                                
                                Text("Tap and hold to reveal your role")
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.green)
                                
                                Text("Role revealed!")
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
        .navigationBarHidden(true)
        .onAppear {
            isRevealed = false
            print("RoleRevealView appeared")
            print("Current session: \(gameService.currentSession != nil ? "exists" : "nil")")
            if let session = gameService.currentSession {
                print("Session players: \(session.players.count)")
                print("Current player index: \(gameService.currentRevealPlayerIndex)")
            }
        }
        .overlay(alignment: .topTrailing) {
            // Development/Testing skip button
            Button(action: {
                gameService.skipRevealPhase()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "forward.fill")
                    Text("Skip")
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.red.opacity(0.8))
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .overlay(alignment: .bottomTrailing) {
            if isRevealed {
                Button("Next Player") {
                    nextPlayer()
                }
                .buttonStyle(.borderedProminent)
                .padding()
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
                    Text(role.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .transition(.opacity)
                    
                    // Role description
                    VStack(spacing: 12) {
                        Text(role.alignment)
                            .font(.headline)
                            .foregroundStyle(role.alignment == "Werewolf" ? .red : .green)
                            .transition(.opacity)
                        
                        Text(role.notes)
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
                        Text("Hold to reveal")
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
                Text("All Roles Revealed!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("The game is about to begin. Pass the device to the first player for the night phase.")
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
