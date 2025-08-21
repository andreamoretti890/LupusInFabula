//
//  OnboardingRolesView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingRolesView: View {
    let onNext: () -> Void
    let onPrevious: () -> Void
    @State private var selectedRole: RoleID = .villager
    @State private var showingRoleDetail = false
    
    private let coreRoles: [RoleID] = [.villager, .werewolf, .seer, .doctor, .hunter]
    private let advancedRoles: [RoleID] = [.jester, .medium, .mayor]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation and progress
            OnboardingNavigationHeader(
                step: .rolesExplanation,
                onPrevious: onPrevious
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    OnboardingStepHeader(step: .rolesExplanation)
                    
                    // Core roles overview
                    VStack(spacing: 20) {
                        SectionHeader(
                            title: "onboarding.roles.core_title",
                            subtitle: "onboarding.roles.core_subtitle"
                        )
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(coreRoles, id: \.self) { role in
                                RoleOverviewCard(
                                    roleID: role,
                                    isSelected: selectedRole == role,
                                    onTap: { selectedRole = role }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Advanced roles preview
                    VStack(spacing: 20) {
                        SectionHeader(
                            title: "onboarding.roles.advanced_title",
                            subtitle: "onboarding.roles.advanced_subtitle"
                        )
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(advancedRoles, id: \.self) { role in
                                AdvancedRolePreviewCard(roleID: role)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Team explanation
                    VStack(spacing: 16) {
                        SectionHeader(
                            title: "onboarding.roles.teams_title",
                            subtitle: "onboarding.roles.teams_subtitle"
                        )
                        
                        HStack(spacing: 16) {
                            TeamCard(
                                alignment: .villager,
                                roles: [.villager, .seer, .doctor, .hunter, .medium, .mayor]
                            )
                            
                            TeamCard(
                                alignment: .werewolf,
                                roles: [.werewolf]
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // Special mention of neutral roles
                        NeutralRoleCard()
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 120)
            }
            
            // Bottom navigation
            OnboardingBottomNavigation(
                primaryTitle: "onboarding.roles.continue",
                onPrimary: onNext,
                onSecondary: onPrevious
            )
        }
    }
}

struct RoleDetailCard: View {
    let roleID: RoleID
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Role icon and name
            VStack(spacing: 12) {
                Text(roleID.defaultEmoji)
                    .font(.system(size: 64))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                VStack(spacing: 4) {
                    Text(roleID.defaultName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(roleID.alignment.displayName)
                        .font(.subheadline)
                        .foregroundStyle(roleID.alignment.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(roleID.alignment.color.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            
            // Role description
            Text(roleID.defaultNotes)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: roleID) { _, _ in
            isAnimating = false
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                isAnimating = true
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                isAnimating = true
            }
        }
    }
}

struct RoleOverviewCard: View {
    let roleID: RoleID
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Text(roleID.defaultEmoji)
                    .font(.system(size: 32))
                
                VStack(spacing: 4) {
                    Text(roleID.defaultName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(roleID.alignment.displayName)
                        .font(.caption)
                        .foregroundStyle(roleID.alignment.color)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? .blue.opacity(0.1) : .gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .blue : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct AdvancedRolePreviewCard: View {
    let roleID: RoleID
    
    var body: some View {
        VStack(spacing: 8) {
            Text(roleID.defaultEmoji)
                .font(.title)
            
            Text(roleID.defaultName)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TeamCard: View {
    let alignment: RoleAlignment
    let roles: [RoleID]
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Image(systemName: alignment == .villager ? "house.fill" : "pawprint.fill")
                    .font(.title2)
                    .foregroundStyle(alignment.color)
                
                Text(alignment.displayName)
                    .font(.headline)
                    .foregroundStyle(alignment.color)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 4) {
                ForEach(roles.prefix(6), id: \.self) { role in
                    Text(role.defaultEmoji)
                        .font(.caption)
                }
            }
            
            Text(alignment == .villager ? "onboarding.roles.team.villager_goal" : "onboarding.roles.team.werewolf_goal")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(alignment.color.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(alignment.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct NeutralRoleCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Text(RoleID.jester.defaultEmoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("onboarding.roles.neutral_title")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("onboarding.roles.neutral_description")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.orange.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.orange.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    OnboardingRolesView(
        onNext: {},
        onPrevious: {}
    )
}
