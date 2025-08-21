//
//  VotingPlayerCard.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import SwiftData
import SwiftUI

struct VotingPlayerCard: View {
    @Environment(GameService.self) private var gameService: GameService
    let player: Player
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                if let role = gameService.getRole(for: player) {
                    Text(role.emoji)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(isSelected ? .red : .blue)
                }
                
                Text(player.displayName)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .red : .primary)
                
                if isSelected {
                    Text("Selected for elimination")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
//            .background(isSelected ? .red.opacity(0.1) : .regularMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .red : .clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
