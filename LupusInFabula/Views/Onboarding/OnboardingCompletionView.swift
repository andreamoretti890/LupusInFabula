//
//  OnboardingCompletionView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingCompletionView: View {
    let onComplete: () -> Void
    @State private var showingCelebration = false
    @State private var confettiOffset: CGFloat = -100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.mint.opacity(0.3), .green.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Confetti animation
                if showingCelebration {
                    ForEach(0..<20, id: \.self) { index in
                        ConfettiPiece(index: index)
                    }
                }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Hero section
                    VStack(spacing: 32) {
                        // Success animation
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(.green.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(showingCelebration ? 1.2 : 1.0)
                                    .animation(
                                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                        value: showingCelebration
                                    )
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.green)
                                    .scaleEffect(showingCelebration ? 1.1 : 1.0)
                                    .animation(
                                        .spring(response: 1.0, dampingFraction: 0.6),
                                        value: showingCelebration
                                    )
                            }
                            
                            VStack(spacing: 16) {
                                Text("onboarding.completion.title")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                
                                Text("onboarding.completion.subtitle")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                        }
                        
                        // Summary of learned concepts
                        VStack(spacing: 20) {
                            Text("onboarding.completion.learned_title")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                LearnedConceptCard(
                                    icon: "gamecontroller.fill",
                                    title: "onboarding.completion.concept.basics",
                                    color: .blue
                                )
                                
                                LearnedConceptCard(
                                    icon: "person.3.fill",
                                    title: "onboarding.completion.concept.roles",
                                    color: .purple
                                )
                                
                                LearnedConceptCard(
                                    icon: "arrow.clockwise",
                                    title: "onboarding.completion.concept.flow",
                                    color: .green
                                )
                                
                                LearnedConceptCard(
                                    icon: "gearshape.fill",
                                    title: "onboarding.completion.concept.setup",
                                    color: .orange
                                )
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                    
                    Spacer()
                    
                    // Call to action section
                    VStack(spacing: 24) {
                        // Encouragement message
                        VStack(spacing: 12) {
                            Text("onboarding.completion.encouragement")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Text("onboarding.completion.next_steps")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)
                        
                        // Primary action
                        Button {
                            // Add haptic feedback
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            onComplete()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("onboarding.completion.start_playing")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 32)
                        .accessibilityLabel("Start playing Lupus in Fabula")
                        .accessibilityHint("Complete onboarding and go to the main app")
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                showingCelebration = true
            }
        }
    }
}

struct LearnedConceptCard: View {
    let icon: String
    let title: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double.random(in: 0...1)),
                    value: isAnimating
                )
            
            Text(title.localized)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.8)) {
                isAnimating = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let index: Int
    @State private var position: CGPoint = CGPoint(x: CGFloat.random(in: 50...350), y: -50)
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
        
    var body: some View {
        Rectangle()
            .fill(colors[index % colors.count])
            .frame(width: 8, height: 8)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .position(position)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: false)
                ) {
                    position.y = UIScreen.main.bounds.height + 50
                    rotation = Double.random(in: 0...720)
                    scale = Double.random(in: 0.5...1.5)
                }
            }
    }
}

#Preview {
    OnboardingCompletionView(onComplete: {})
}
