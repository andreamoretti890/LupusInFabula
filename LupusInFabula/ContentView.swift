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
    @State private var showingOnboarding = false
    @State private var isCheckingOnboarding = true
    
    init() {
        // We need to create GameService with a temporary model context
        // It will be properly initialized when the view appears
        let tempContainer = try! ModelContainer(for: Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self, FrequentPlayer.self, OnboardingState.self)
        let tempContext = ModelContext(tempContainer)
        _gameService = State(wrappedValue: GameService(modelContext: tempContext))
    }
    
    var body: some View {
        Group {
            if isCheckingOnboarding {
                // Loading state while checking onboarding
                VStack(spacing: 24) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                    
                    Text("Loading...")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            } else if showingOnboarding {
                OnboardingContainerView()
                    .environment(gameService)
            } else {
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
            }
        }
        .onAppear {
            // Update GameService with the proper model context when view appears
            gameService.updateModelContext(modelContext)
            checkOnboardingStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showingOnboarding = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingRequested)) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                showingOnboarding = true
            }
        }
    }
    
    private func checkOnboardingStatus() {
        do {
            let descriptor = FetchDescriptor<OnboardingState>()
            let states = try modelContext.fetch(descriptor)
            
            if let onboardingState = states.first {
                showingOnboarding = !onboardingState.hasCompletedOnboarding
            } else {
                // First launch - show onboarding
                showingOnboarding = true
            }
            
            isCheckingOnboarding = false
        } catch {
            print("Error checking onboarding status: \(error)")
            // Default to showing onboarding on error
            showingOnboarding = true
            isCheckingOnboarding = false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self, FrequentPlayer.self, OnboardingState.self], inMemory: true)
}
