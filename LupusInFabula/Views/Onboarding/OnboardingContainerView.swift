//
//  OnboardingContainerView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.modelContext) private var modelContext
    @State private var currentStep: OnboardingStep = .welcome
    @State private var onboardingState: OnboardingState?
    
    var body: some View {
        Group {
            switch currentStep {
            case .welcome:
                OnboardingWelcomeView(onNext: advanceToNext)
            case .gameOverview:
                OnboardingGameOverviewView(onNext: advanceToNext, onPrevious: goToPrevious)
            case .rolesExplanation:
                OnboardingRolesView(onNext: advanceToNext, onPrevious: goToPrevious)
            case .gameFlow:
                OnboardingGameFlowView(onNext: advanceToNext, onPrevious: goToPrevious)
            case .setupDemo:
                OnboardingSetupDemoView(onNext: advanceToNext, onPrevious: goToPrevious)
            case .completion:
                OnboardingCompletionView(onComplete: completeOnboarding)
            }
        }
        .onAppear {
            loadOnboardingState()
        }
    }
    
    private func loadOnboardingState() {
        do {
            let descriptor = FetchDescriptor<OnboardingState>()
            let states = try modelContext.fetch(descriptor)
            
            if let state = states.first {
                onboardingState = state
                currentStep = OnboardingStep(rawValue: state.currentStep) ?? .welcome
            } else {
                // Create new onboarding state
                let newState = OnboardingState()
                modelContext.insert(newState)
                onboardingState = newState
                try modelContext.save()
            }
        } catch {
            print("Error loading onboarding state: \(error)")
            // Fallback to default state
            currentStep = .welcome
        }
    }
    
    private func advanceToNext() {
        let nextStepRawValue = currentStep.rawValue + 1
        guard let nextStep = OnboardingStep(rawValue: nextStepRawValue) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = nextStep
        }
        
        updateOnboardingState()
    }
    
    private func goToPrevious() {
        let previousStepRawValue = currentStep.rawValue - 1
        guard let previousStep = OnboardingStep(rawValue: previousStepRawValue) else {
            return
        }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = previousStep
        }
        
        updateOnboardingState()
    }
    
    private func updateOnboardingState() {
        onboardingState?.updateStep(currentStep.rawValue)
        
        do {
            try modelContext.save()
        } catch {
            print("Error updating onboarding state: \(error)")
        }
    }
    
    private func completeOnboarding() {
        onboardingState?.markCompleted()
        
        do {
            try modelContext.save()
        } catch {
            print("Error completing onboarding: \(error)")
        }
        
        // Notify the app that onboarding is complete
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }
}

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
    static let onboardingRequested = Notification.Name("onboardingRequested")
}

#Preview {
    let tempContainer = try! ModelContainer(for: OnboardingState.self, Role.self, RolePreset.self, SavedConfig.self, GameSession.self, GameSettings.self)
    let tempContext = ModelContext(tempContainer)
    let gameService = GameService(modelContext: tempContext)
    
    OnboardingContainerView()
        .environment(gameService)
        .modelContainer(tempContainer)
}
