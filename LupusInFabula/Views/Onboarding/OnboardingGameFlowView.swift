//
//  OnboardingGameFlowView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 25/08/25.
//

import SwiftUI

struct OnboardingGameFlowView: View {
    let onNext: () -> Void
    let onPrevious: () -> Void
    @State private var currentDemo = 0
    
    private let flowDemos = [
        FlowDemo(
            phase: "onboarding.flow.demo.setup",
            icon: "gearshape.fill",
            color: .blue,
            steps: [
                "onboarding.flow.demo.setup.step1",
                "onboarding.flow.demo.setup.step2",
                "onboarding.flow.demo.setup.step3"
            ]
        ),
        FlowDemo(
            phase: "onboarding.flow.demo.night",
            icon: "moon.fill",
            color: .indigo,
            steps: [
                "onboarding.flow.demo.night.step1",
                "onboarding.flow.demo.night.step2",
                "onboarding.flow.demo.night.step3"
            ]
        ),
        FlowDemo(
            phase: "onboarding.flow.demo.day",
            icon: "sun.max.fill",
            color: .orange,
            steps: [
                "onboarding.flow.demo.day.step1",
                "onboarding.flow.demo.day.step2",
                "onboarding.flow.demo.day.step3"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation and progress
            OnboardingNavigationHeader(
                step: .gameFlow,
                onPrevious: onPrevious
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    OnboardingStepHeader(step: .gameFlow)
                    
                    // Interactive flow demonstration
                    VStack(spacing: 24) {
                        Text("onboarding.flow.interactive_title")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        // Flow demo carousel
                        TabView(selection: $currentDemo) {
                            ForEach(0..<flowDemos.count, id: \.self) { index in
                                FlowDemoCard(demo: flowDemos[index])
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 340)
                        
                        // Demo navigation
                        HStack(spacing: 20) {
                            ForEach(0..<flowDemos.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentDemo = index
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: flowDemos[index].icon)
                                            .font(.title3)
                                            .foregroundStyle(index == currentDemo ? flowDemos[index].color : .secondary)
                                        
                                        Text(flowDemos[index].phase.localized)
                                            .font(.caption)
                                            .fontWeight(index == currentDemo ? .semibold : .regular)
                                            .foregroundStyle(index == currentDemo ? flowDemos[index].color : .secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Game cycle explanation
                    VStack(spacing: 20) {
                        SectionHeader(
                            title: "onboarding.flow.cycle_title",
                            subtitle: "onboarding.flow.cycle_subtitle"
                        )
                        
                        GameCycleVisualization()
                            .padding(.horizontal, 24)
                    }
                    
                    // Key tips
                    VStack(spacing: 16) {
                        SectionHeader(
                            title: "onboarding.flow.tips_title",
                            subtitle: "onboarding.flow.tips_subtitle"
                        )
                        
                        VStack(spacing: 12) {
                            OnboardingTipRow(
                                icon: "lightbulb.fill",
                                tip: "onboarding.flow.tip.discussion"
                            )
                            
                            OnboardingTipRow(
                                icon: "eye.fill",
                                tip: "onboarding.flow.tip.observation"
                            )
                            
                            OnboardingTipRow(
                                icon: "person.2.fill",
                                tip: "onboarding.flow.tip.teamwork"
                            )
                            
                            OnboardingTipRow(
                                icon: "theatermasks.fill",
                                tip: "onboarding.flow.tip.deception"
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 120)
            }
            
            // Bottom navigation
            OnboardingBottomNavigation(
                primaryTitle: "onboarding.flow.continue",
                onPrimary: onNext,
                onSecondary: onPrevious
            )
        }
    }
}

struct FlowDemo {
    let phase: String
    let icon: String
    let color: Color
    let steps: [String]
}

struct FlowDemoCard: View {
    let demo: FlowDemo
    @State private var currentStep = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 24) {
            // Phase header
            VStack(spacing: 12) {
                Image(systemName: demo.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(demo.color)
                
                Text(demo.phase.localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(demo.color)
            }
            
            // Steps demonstration
            VStack(spacing: 16) {
                ForEach(0..<demo.steps.count, id: \.self) { index in
                    HStack(spacing: 12) {
                        // Step indicator
                        ZStack {
                            Circle()
                                .fill(getStepColor(index: index))
                                .frame(width: 24, height: 24)
                            
                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            } else if index == currentStep {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                            } else {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        // Step text
                        Text(demo.steps[index].localized)
                            .font(.subheadline)
                            .fontWeight(index == currentStep ? .semibold : .regular)
                            .foregroundStyle(index <= currentStep ? .primary : .secondary)
                        
                        Spacer()
                    }
                    .opacity(index <= currentStep ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            
            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            startStepAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func getStepColor(index: Int) -> Color {
        if index < currentStep {
            return .green
        } else if index == currentStep {
            return demo.color
        } else {
            return .secondary.opacity(0.3)
        }
    }
    
    private func startStepAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentStep = (currentStep + 1) % (demo.steps.count + 1)
            }
        }
    }
}

struct GameCycleVisualization: View {
    @State private var currentPhase = 0
    private let phases = ["Setup", "Night", "Day", "Repeat"]
    private let phaseColors: [Color] = [.blue, .indigo, .orange, .green]
    
    var body: some View {
        VStack(spacing: 24) {
            // Circular flow diagram
            ZStack {
                // Background circle
                Circle()
                    .stroke(.secondary.opacity(0.2), lineWidth: 4)
                    .frame(width: 200, height: 200)
                
                // Phase indicators
                ForEach(0..<phases.count, id: \.self) { index in
                    let angle = Double(index) * 90 - 90 // Start from top
                    let isActive = index == currentPhase
                    
                    VStack(spacing: 4) {
                        Circle()
                            .fill(isActive ? phaseColors[index] : .secondary.opacity(0.3))
                            .frame(width: isActive ? 20 : 16, height: isActive ? 20 : 16)
                            .scaleEffect(isActive ? 1.2 : 1.0)
                        
                        Text(phases[index])
                            .font(.caption)
                            .fontWeight(isActive ? .bold : .regular)
                            .foregroundStyle(isActive ? phaseColors[index] : .secondary)
                    }
                    .offset(
                        x: cos(angle * .pi / 180) * 100,
                        y: sin(angle * .pi / 180) * 100
                    )
                    .animation(.easeInOut(duration: 0.5), value: currentPhase)
                }
                
                // Center text
                VStack(spacing: 4) {
                    Text("onboarding.flow.cycle_current")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(phases[currentPhase])
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(phaseColors[currentPhase])
                }
            }
            
            // Progress description
            Text("onboarding.flow.cycle_description")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            startCycleAnimation()
        }
    }
    
    private func startCycleAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPhase = (currentPhase + 1) % phases.count
            }
        }
    }
}

struct OnboardingTipRow: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 24)
            
            Text(tip.localized)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    OnboardingGameFlowView(
        onNext: {},
        onPrevious: {}
    )
}
