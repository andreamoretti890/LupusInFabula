//
//  GameEndView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import SwiftUI

struct GameEndView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(GameService.self) private var gameService: GameService
    let message: String
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            
            VStack(spacing: 16) {
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(message)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Back to Home") {
                dismiss()
                gameService.endGameAndReturnHome()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(40)
    }
}

#Preview {
    GameEndView(message: "Test game end message")
}
