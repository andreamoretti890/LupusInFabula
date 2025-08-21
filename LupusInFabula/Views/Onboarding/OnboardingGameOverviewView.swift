//
//  OnboardingGameOverviewView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingGameOverviewView: View {
    let onNext: () -> Void
    let onPrevious: () -> Void
    @State private var currentPhase = 0
    
    private let gamePhases = [
        GamePhaseInfo(
            icon: "gearshape.fill",
            title: "onboarding.overview.setup.title",
            description: "onboarding.overview.setup.description",
            color: .blue
        ),
        GamePhaseInfo(
            icon: "eye.fill",
            title: "onboarding.overview.reveal.title",
            description: "onboarding.overview.reveal.description",
            color: .purple
        ),
        GamePhaseInfo(
            icon: "moon.fill",
            title: "onboarding.overview.night.title",
            description: "onboarding.overview.night.description",
            color: .indigo
        ),
        GamePhaseInfo(
            icon: "sun.max.fill",
            title: "onboarding.overview.day.title",
            description: "onboarding.overview.day.description",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation and progress
            OnboardingNavigationHeader(
                step: .gameOverview,
                onPrevious: onPrevious
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    OnboardingStepHeader(step: .gameOverview)
                    
                    // Interactive game flow demonstration
                    VStack(spacing: 24) {
                        Text("onboarding.overview.flow_title")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        // Phase carousel
                        TabView(selection: $currentPhase) {
                            ForEach(0..<gamePhases.count, id: \.self) { index in
                                GamePhaseCard(phase: gamePhases[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 280)
                        
                        // Custom page indicators
                        HStack(spacing: 8) {
                            ForEach(0..<gamePhases.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPhase ? gamePhases[index].color : Color.secondary.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == currentPhase ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: currentPhase)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Key concepts
                    VStack(spacing: 16) {
                        Text("onboarding.overview.key_concepts")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            OnboardingConceptRow(
                                icon: "person.2.fill",
                                title: "onboarding.overview.concept.teams",
                                description: "onboarding.overview.concept.teams_desc"
                            )
                            
                            OnboardingConceptRow(
                                icon: "clock.fill",
                                title: "onboarding.overview.concept.phases",
                                description: "onboarding.overview.concept.phases_desc"
                            )
                            
                            OnboardingConceptRow(
                                icon: "trophy.fill",
                                title: "onboarding.overview.concept.victory",
                                description: "onboarding.overview.concept.victory_desc"
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 120)
            }
            
            // Bottom navigation
            OnboardingBottomNavigation(
                primaryTitle: "onboarding.overview.continue",
                onPrimary: onNext,
                onSecondary: onPrevious
            )
        }
        .onAppear {
            startAutoAdvance()
        }
    }
    
    private func startAutoAdvance() {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPhase = (currentPhase + 1) % gamePhases.count
            }
        }
    }
}

struct GamePhaseInfo {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct GamePhaseCard: View {
    let phase: GamePhaseInfo
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Icon
            Image(systemName: phase.icon)
                .font(.system(size: 60))
                .foregroundStyle(phase.color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Content
            VStack(spacing: 12) {
                Text(phase.title.localized)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(phase.description.localized)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: phase.color.opacity(0.2), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                isAnimating = true
            }
        }
    }
}

struct OnboardingConceptRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title.localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description.localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OnboardingGameOverviewView(
        onNext: {},
        onPrevious: {}
    )
}
