//
//  OnboardingSharedComponents.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

// MARK: - Navigation Header
struct OnboardingNavigationHeader: View {
    let step: OnboardingStep
    let onPrevious: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Top navigation
            HStack {
                Button(action: onPrevious) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.blue)
                }
                
                Spacer()
                
                // Progress indicator
                OnboardingProgressIndicator(currentStep: step)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            
            Divider()
        }
    }
}

// MARK: - Progress Indicator
struct OnboardingProgressIndicator: View {
    let currentStep: OnboardingStep
    
    private var progress: Double {
        Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Progress bar
            HStack(spacing: 4) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Rectangle()
                        .fill(step.rawValue <= currentStep.rawValue ? .blue : .secondary.opacity(0.3))
                        .frame(width: 24, height: 4)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            
            // Step indicator text
            Text("\(currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Step Header
struct OnboardingStepHeader: View {
    let step: OnboardingStep
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            Image(systemName: step.systemImage)
                .font(.system(size: 64))
                .foregroundStyle(Color(step.primaryColor))
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            // Title and subtitle
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(step.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.top, 32)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title.localized)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(subtitle.localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

// MARK: - Bottom Navigation
struct OnboardingBottomNavigation: View {
    let primaryTitle: LocalizedStringKey
    let secondaryTitle: String?
    let onPrimary: () -> Void
    let onSecondary: (() -> Void)?
    
    init(
        primaryTitle: LocalizedStringKey,
        secondaryTitle: String? = "Previous",
        onPrimary: @escaping () -> Void,
        onSecondary: (() -> Void)? = nil
    ) {
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Secondary action (if provided)
                if let onSecondary = onSecondary, let secondaryTitle = secondaryTitle {
                    Button(action: onSecondary) {
                        Text(secondaryTitle.localized)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Primary action
                Button(action: onPrimary) {
                    HStack(spacing: 8) {
                        Text(primaryTitle)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Animated Button
struct OnboardingAnimatedButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let action: () -> Void
    @State private var isPressed = false
    
    enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        
        var backgroundColor: Color {
            switch self {
            case .primary: return .blue
            case .secondary: return .clear
            case .tertiary: return .gray.opacity(0.2)
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .white
            case .secondary: return .blue
            case .tertiary: return .primary
            }
        }
        
        var borderColor: Color? {
            switch self {
            case .primary: return nil
            case .secondary: return .blue
            case .tertiary: return nil
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title.localized)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(style.backgroundColor)
            .foregroundStyle(style.foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(style.borderColor ?? Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Feature Highlight Card
struct OnboardingFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(color)
                .frame(width: 60, height: 60)
                .background(color.opacity(0.1))
                .clipShape(Circle())
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    .easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double.random(in: 0...1)),
                    value: isAnimating
                )
            
            VStack(spacing: 8) {
                Text(title.localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(description.localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Loading Animation
struct OnboardingLoadingAnimation: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Image(systemName: "moon.stars.fill")
            .font(.system(size: 32))
            .foregroundStyle(.orange)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

#Preview("Navigation Header") {
    OnboardingNavigationHeader(step: .gameOverview, onPrevious: {})
}

#Preview("Step Header") {
    OnboardingStepHeader(step: .welcome)
}

#Preview("Bottom Navigation") {
    OnboardingBottomNavigation(
        primaryTitle: "Continue",
        onPrimary: {},
        onSecondary: {}
    )
}
