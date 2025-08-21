//
//  SettingsView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsQuery: [GameSettings]
    @State private var settings: GameSettings
    @State private var showingResetAlert = false
    
    init() {
        // Initialize with default settings - will be updated in onAppear
        _settings = State(initialValue: GameSettings())
    }
    
    var userPrimaryLanguage: String {
        let locale = Locale.autoupdatingCurrent
        guard let primaryLanguage = locale.language.languageCode?.identifier else {
            return "Language code not found"
        }
        return NSLocale.current.localizedString(forLanguageCode: primaryLanguage) ?? "Language not found"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Link(destination: URL(string: UIApplication.openSettingsURLString)!, label: {
                    HStack {
                        Text("settings.app_language")
                        Spacer()
                        Text(userPrimaryLanguage.capitalized)
                            .foregroundStyle(.secondary)
                    }
                })
                .foregroundStyle(.primary)
                
                Section {
                    Button(action: replayOnboarding) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                                .foregroundStyle(.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("settings.replay_onboarding")
                                    .foregroundStyle(.primary)
                                
                                Text("settings.replay_onboarding_description")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.orange)
                                .font(.title2)
                            Text("settings.house_rules.title")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Text("settings.house_rules.description")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    EmptyView()
                }
                
                Section("settings.phase_controls.title") {
                    Toggle(isOn: Bindable(settings).allowSkipWerewolfKill) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings.skip_werewolf_kill.title")
                                .font(.body)
                            Text("settings.skip_werewolf_kill.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).allowSkipDayVoting) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings.skip_day_voting.title")
                                .font(.body)
                            Text("settings.skip_day_voting.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).allowSkipHunterRevenge) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings.skip_hunter_revenge.title")
                                .font(.body)
                            Text("settings.skip_hunter_revenge.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Section("settings.timer.title") {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("settings.phase_timer.title")
                                    .font(.body)
                                Spacer()
                                Text(settings.timerDisplayText)
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                            
                            Text("settings.phase_timer.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(settings.phaseTimer) },
                                set: { settings.phaseTimer = Int($0) }
                            ), in: 0...180, step: 15) {
                                Text("\(settings.phaseTimer)")
                            } minimumValueLabel: {
                                Text(GameSettings.minPhaseTimerDuration.formatted(.units(width: .narrow)))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            } maximumValueLabel: {
                                Text(GameSettings.maxPhaseTimerDuration.formatted(.units(width: .narrow)))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .accentColor(.orange)
                        }
                        
                        if settings.phaseTimer > 0 {
                            HStack {
                                Stepper("", value: Bindable(settings).phaseTimer, in: 30...180, step: 30)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Text(String(localized: "settings.exact_seconds \(settings.phaseTimer)"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("settings.doctor_rules.title") {
                    Toggle(isOn: Bindable(settings).doctorCanSaveHimself) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings.doctor_save_himself.title")
                                .font(.body)
                            Text("settings.doctor_save_himself.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).doctorCanSaveSamePersonTwice) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settings.doctor_save_same_twice.title")
                                .font(.body)
                            Text("settings.doctor_save_same_twice.description")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Section {
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("settings.reset_to_defaults.title")
                        }
                        .foregroundStyle(.orange)
                        .font(.body)
                        .fontWeight(.medium)
                    }
                } footer: {
                    Text("settings.reset_to_defaults.footer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark", role: .confirm) {
                        saveSettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadOrCreateSettings()
        }
        .alert("settings.reset_confirmation.title", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("settings.reset_confirmation.message")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadOrCreateSettings() {
        if let existingSettings = settingsQuery.first {
            settings = existingSettings
        } else {
            // Create default settings
            let defaultSettings = GameSettings()
            modelContext.insert(defaultSettings)
            settings = defaultSettings
            
            do {
                try modelContext.save()
            } catch {
                print("Error creating default settings: \(error)")
            }
        }
    }
    
    private func saveSettings() {
        settings.lastUpdated = Date()
        
        do {
            try modelContext.save()
            print("Settings saved successfully")
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    private func performReset() {
        settings.resetToDefaults()
        
        do {
            try modelContext.save()
            print("Settings reset to defaults")
        } catch {
            print("Error resetting settings: \(error)")
        }
    }
    
    private func replayOnboarding() {
        do {
            let descriptor = FetchDescriptor<OnboardingState>()
            let states = try modelContext.fetch(descriptor)
            
            if let onboardingState = states.first {
                onboardingState.hasCompletedOnboarding = false
                onboardingState.currentStep = 0
                onboardingState.lastUpdated = Date()
            } else {
                // Create new onboarding state
                let newState = OnboardingState()
                modelContext.insert(newState)
            }
            
            try modelContext.save()
            
            // Dismiss settings and trigger onboarding
            dismiss()
            
            // Notify the app to show onboarding
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .onboardingRequested, object: nil)
            }
        } catch {
            print("Error resetting onboarding state: \(error)")
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [GameSettings.self], inMemory: true)
        .environment(\.locale, Locale(identifier: "it_IT"))
}
