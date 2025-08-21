//
//  OnboardingWelcomeView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    let onNext: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Hero section
                VStack(spacing: 32) {
                    Spacer()
                    
                    // App icon with animation
                    VStack(spacing: 24) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .rotation3DEffect(
                                .degrees(isAnimating ? 5 : -5),
                                axis: (x: 1, y: 1, z: 0)
                            )
                            .animation(
                                .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                        
                        VStack(spacing: 16) {
                            Text("onboarding.welcome.title")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                            Text("onboarding.welcome.subtitle")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }
                    
                    Spacer()
                }
                
                // Bottom section with CTA
                VStack(spacing: 24) {
                    // Key features preview
                    HStack(spacing: 24) {
                        OnboardingFeatureHighlight(
                            icon: "person.3.fill",
                            title: "onboarding.welcome.feature.multiplayer",
                            color: .blue
                        )
                        
                        OnboardingFeatureHighlight(
                            icon: "eye.slash.fill",
                            title: "onboarding.welcome.feature.private",
                            color: .green
                        )
                        
                        OnboardingFeatureHighlight(
                            icon: "gamecontroller.fill",
                            title: "onboarding.welcome.feature.fun",
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 32)
                    
                    // Primary CTA
                    Button(action: onNext) {
                        HStack(spacing: 12) {
                            Text("onboarding.welcome.get_started")
                                .fontWeight(.semibold)
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 32)
                    .accessibilityLabel("Get started with Lupus in Fabula")
                    .accessibilityHint("Begin the app introduction")
                }
                .padding(.bottom, 48)
            }
        }
        .background(
            LinearGradient(
                colors: [.black.opacity(0.1), .blue.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                isAnimating = true
            }
        }
    }
}

struct OnboardingFeatureHighlight: View {
    let icon: String
    let title: LocalizedStringKey
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    OnboardingWelcomeView(onNext: {})
        .environment(\.locale, Locale(identifier: "en"))
}
