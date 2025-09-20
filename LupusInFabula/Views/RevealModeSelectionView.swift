//
//  RevealModeSelectionView.swift
//  LupusInFabula
//
//  Created by AI on 30/08/25.
//

import SwiftUI

struct RevealModeSelectionView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Choose Role Reveal Method")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("How would you like to reveal roles to players?")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Mode selection
                VStack(spacing: 16) {
                    ForEach(RoleRevealMode.allCases, id: \.self) { mode in
                        RevealModeCard(
                            mode: mode,
                            isSelected: gameService.selectedRevealMode == mode,
                            onSelect: {
                                gameService.selectedRevealMode = mode
                            }
                        )
                    }
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button("Continue to Game") {
                        gameService.startGame()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!gameService.isSetupValid())
                    
                    Button("Back to Setup") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            }
            .padding(24)
            .navigationTitle("Reveal Method")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RevealModeCard: View {
    let mode: RoleRevealMode
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .blue)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(isSelected ? .blue : .blue.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.displayName)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    Text(mode.description)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? .blue : .clear)
                    .stroke(isSelected ? .clear : .blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RevealModeSelectionView()
}
