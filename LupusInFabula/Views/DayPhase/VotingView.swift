//
//  VotingView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import SwiftData
import SwiftUI

struct VotingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    @State private var selectedPlayer: Player?
    @State private var showingResults = false
    @State private var votingComplete = false
    @Binding var showingHunterRevenge: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("voting.title".localized)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("voting.description".localized)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Phase Timer for voting
                if let settings = gameService.gameSettings, settings.phaseTimer > 0 {
                    PhaseTimerView(totalSeconds: settings.phaseTimer) {
                        // Auto-submit vote when timer expires
                        handleVotingTimerExpired()
                    }
                    .padding(.horizontal, 24)
                }
                
                // Player selection
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(gameService.getAlivePlayers(), id: \.id) { player in
                            VotingPlayerCard(
                                player: player,
                                isSelected: selectedPlayer?.id == player.id,
                                onSelect: { selectedPlayer = player }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                // Vote button
                Button(action: submitVote) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("voting.submit_vote".localized)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPlayer != nil ? .blue : .gray)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedPlayer == nil)
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingResults, onDismiss: {
            // When results view is dismissed, mark voting as complete
            votingComplete = true
        }) {
            VotingResultsView(eliminatedPlayer: selectedPlayer, showingHunterRevenge: $showingHunterRevenge)
        }
        .onChange(of: votingComplete) { _, isComplete in
            if isComplete {
                // Dismiss the voting view when voting process is complete
                dismiss()
            }
        }
    }
    
    private func submitVote() {
        guard let player = selectedPlayer else { return }
        
        // In a real implementation, this would record the vote
        print("Vote submitted to eliminate \(player.displayName)")
        
        showingResults = true
    }
    
    private func handleVotingTimerExpired() {
        // Auto-submit vote with current selection, or no elimination
        showingResults = true
    }
}
