//
//  OnboardingState.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class OnboardingState {
    @Attribute(.unique) var id: String
    var hasCompletedOnboarding: Bool
    var currentStep: Int
    var lastUpdated: Date
    
    init(id: String = "default", hasCompletedOnboarding: Bool = false, currentStep: Int = 0, lastUpdated: Date = Date()) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.currentStep = currentStep
        self.lastUpdated = lastUpdated
    }
    
    func markCompleted() {
        hasCompletedOnboarding = true
        lastUpdated = Date()
    }
    
    func updateStep(_ step: Int) {
        currentStep = step
        lastUpdated = Date()
    }
}

// MARK: - Onboarding Step Definition
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case gameOverview = 1
    case rolesExplanation = 2
    case gameFlow = 3
    case setupDemo = 4
    case completion = 5
    
    var title: String {
        switch self {
        case .welcome:
            return "onboarding.welcome.title".localized
        case .gameOverview:
            return "onboarding.overview.title".localized
        case .rolesExplanation:
            return "onboarding.roles.title".localized
        case .gameFlow:
            return "onboarding.flow.title".localized
        case .setupDemo:
            return "onboarding.demo.title".localized
        case .completion:
            return "onboarding.completion.title".localized
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "onboarding.welcome.subtitle".localized
        case .gameOverview:
            return "onboarding.overview.subtitle".localized
        case .rolesExplanation:
            return "onboarding.roles.subtitle".localized
        case .gameFlow:
            return "onboarding.flow.subtitle".localized
        case .setupDemo:
            return "onboarding.demo.subtitle".localized
        case .completion:
            return "onboarding.completion.subtitle".localized
        }
    }
    
    var systemImage: String {
        switch self {
        case .welcome:
            return "hand.wave.fill"
        case .gameOverview:
            return "gamecontroller.fill"
        case .rolesExplanation:
            return "person.3.fill"
        case .gameFlow:
            return "arrow.clockwise"
        case .setupDemo:
            return "gear.badge"
        case .completion:
            return "checkmark.circle.fill"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .welcome:
            return .blue
        case .gameOverview:
            return .orange
        case .rolesExplanation:
            return .purple
        case .gameFlow:
            return .green
        case .setupDemo:
            return .indigo
        case .completion:
            return .mint
        }
    }
}
