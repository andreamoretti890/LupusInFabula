//
//  VotingResultsView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import SwiftData
import SwiftUI

struct VotingResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    let eliminatedPlayer: Player?
    @Binding var showingHunterRevenge: Bool
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
                    
                    // Check for Hunter revenge after elimination
                    if gameService.hasPendingHunterRevenge() {
                        // Don't navigate to night yet, wait for Hunter revenge
                        dismiss()
                        return
                    }
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
                
                // Check for Hunter revenge after elimination
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if gameService.hasPendingHunterRevenge() {
                        showingHunterRevenge = true
                    }
                }
            }
        }
    }
}
