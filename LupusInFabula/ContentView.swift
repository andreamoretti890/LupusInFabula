//
//  ContentView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameService: GameService
    
    init() {
        // We need to create GameService with a temporary model context
        // It will be properly initialized when the view appears
        let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
        let tempContext = ModelContext(tempContainer)
        _gameService = State(wrappedValue: GameService(modelContext: tempContext))
    }
    
    var body: some View {
        NavigationStack(path: $gameService.navigationPath) {
            HomeView()
                .navigationDestination(for: GamePhase.self) { phase in
                    switch phase {
                    case .setup:
                        GameSetupView()
                    case .reveal:
                        RoleRevealView()
                    case .night:
                        NightPhaseView()
                    case .day:
                        DayPhaseView()
                    }
                }
        }
        .environment(gameService)
        .onAppear {
            // Update GameService with the proper model context when view appears
            gameService.updateModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self], inMemory: true)
}
