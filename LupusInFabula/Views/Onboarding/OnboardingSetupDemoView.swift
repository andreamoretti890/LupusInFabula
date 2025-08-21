//
//  OnboardingSetupDemoView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingSetupDemoView: View {
    let onNext: () -> Void
    let onPrevious: () -> Void
    @State private var selectedPlayerCount = 6
    @State private var selectedPreset = "beginner_6"
    @State private var showingCustomization = false
    
    private let playerCountOptions = [4, 6, 8, 10, 12]
    private let presetOptions = [
        ("beginner_6", "Beginner (6 players)", "Perfect for first-time players"),
        ("classic_8", "Classic (8 players)", "Balanced gameplay experience"),
        ("advanced_10", "Advanced (10 players)", "Includes special roles")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation and progress
            OnboardingNavigationHeader(
                step: .setupDemo,
                onPrevious: onPrevious
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    OnboardingStepHeader(step: .setupDemo)
                    
                    // Interactive setup demo
                    VStack(spacing: 24) {
                        Text("onboarding.demo.interactive_title")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        // Step 1: Player count selection
                        SetupStepCard(
                            stepNumber: 1,
                            title: "onboarding.demo.step1_title",
                            description: "onboarding.demo.step1_description"
                        ) {
//                            VStack(spacing: 16) {
//                                Text("onboarding.demo.player_count")
//                                    .font(.subheadline)
//                                    .fontWeight(.medium)
                                
//                                Picker("Player Count", selection: $selectedPlayerCount) {
//                                    ForEach(playerCountOptions, id: \.self) { count in
//                                        Text("\(count) players")
//                                            .tag(count)
//                                    }
//                                }
//                                .pickerStyle(.segmented)
//                            }
                        }
                        
                        // Step 2: Preset selection
                        SetupStepCard(
                            stepNumber: 2,
                            title: "onboarding.demo.step2_title",
                            description: "onboarding.demo.step2_description"
                        ) {
//                            VStack(spacing: 12) {
//                                ForEach(presetOptions, id: \.0) { preset in
//                                    PresetOptionCard(
//                                        id: preset.0,
//                                        name: preset.1,
//                                        description: preset.2,
//                                        isSelected: selectedPreset == preset.0,
//                                        onSelect: { selectedPreset = preset.0 }
//                                    )
//                                }
//                            }
                        }
                        
                        // Step 3: Customization option
                        SetupStepCard(
                            stepNumber: 3,
                            title: "onboarding.demo.step3_title",
                            description: "onboarding.demo.step3_description"
                        ) {
                            VStack(spacing: 16) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showingCustomization.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: showingCustomization ? "chevron.down" : "chevron.right")
                                        Text("onboarding.demo.customize_roles")
                                        Spacer()
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.blue)
                                }
                                .buttonStyle(.plain)
                                
                                if showingCustomization {
                                    CustomizationPreview()
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Quick tips section
                    VStack(spacing: 20) {
                        SectionHeader(
                            title: "onboarding.demo.tips_title",
                            subtitle: "onboarding.demo.tips_subtitle"
                        )
                        
                        VStack(spacing: 12) {
                            OnboardingTipRow(
                                icon: "person.3.fill",
                                tip: "onboarding.demo.tip.player_count"
                            )
                            
                            OnboardingTipRow(
                                icon: "bookmark.fill",
                                tip: "onboarding.demo.tip.presets"
                            )
                            
                            OnboardingTipRow(
                                icon: "gearshape.2.fill",
                                tip: "onboarding.demo.tip.customization"
                            )
                            
                            OnboardingTipRow(
                                icon: "arrow.clockwise",
                                tip: "onboarding.demo.tip.reuse"
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Ready to play call-out
                    ReadyToPlayCard()
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 120)
            }
            
            // Bottom navigation
            OnboardingBottomNavigation(
                primaryTitle: "onboarding.demo.continue",
                onPrimary: onNext,
                onSecondary: onPrevious
            )
        }
    }
}

struct SetupStepCard<Content: View>: View {
    let stepNumber: Int
    let title: String
    let description: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 16) {
            // Step header
            HStack(spacing: 12) {
                // Step number
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 32, height: 32)
                    
                    Text("\(stepNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(description.localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Interactive content
            content
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct PresetOptionCard: View {
    let id: String
    let name: String
    let description: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? .blue : .clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? .blue : .secondary, lineWidth: 2)
                        )
                    
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct CustomizationPreview: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("onboarding.demo.customization_preview")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                CustomRolePreview(emoji: "🐺", name: "Werewolf", count: 1)
                CustomRolePreview(emoji: "👤", name: "Villager", count: 3)
                CustomRolePreview(emoji: "🔮", name: "Seer", count: 1)
                CustomRolePreview(emoji: "💊", name: "Doctor", count: 1)
            }
        }
        .padding(16)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CustomRolePreview: View {
    let emoji: String
    let name: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.title3)
            
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("\(count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReadyToPlayCard: View {
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.title)
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("onboarding.demo.ready_title")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("onboarding.demo.ready_description")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(20)
        .background(.green.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.green.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    OnboardingSetupDemoView(
        onNext: {},
        onPrevious: {}
    )
    .environment(\.locale, Locale(identifier: "it_IT"))
}
