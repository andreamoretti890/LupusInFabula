//
//  LupusInFabulaApp.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI
import SwiftData

@main
struct LupusInFabulaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Role.self,
            RolePreset.self,
            SavedConfig.self,
            GameSession.self,
            GameSettings.self,
            FrequentPlayer.self,
            OnboardingState.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
