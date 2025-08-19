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
    @Environment(\.dismiss) private var dismiss
    
    @Query private var settingsQuery: [GameSettings]
    @State private var settings: GameSettings
    @State private var showingResetAlert = false
    
    init() {
        // Initialize with default settings - will be updated in onAppear
        _settings = State(initialValue: GameSettings())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(.orange)
                                .font(.title2)
                            Text("House Rules")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        Text("Configure gameplay options and narrator controls")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                } header: {
                    EmptyView()
                }
                
                Section("Phase Controls") {
                    Toggle(isOn: Bindable(settings).allowSkipWerewolfKill) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Allow Skipping Werewolf Kill Phase")
                                .font(.body)
                            Text("Shows a 'Skip Kill Phase' button during werewolf turns")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).allowSkipDayVoting) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Allow Skipping Day Voting Phase")
                                .font(.body)
                            Text("Shows a 'Skip Voting Phase' button during day discussions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).allowSkipHunterRevenge) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Allow Skipping Hunter Revenge")
                                .font(.body)
                            Text("Shows a 'Skip Revenge' button when Hunter is eliminated")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                }
                
                Section("Timer Settings") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Phase Timer")
                                .font(.body)
                            Spacer()
                            Text(settings.timerDisplayText)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        
                        Text("Optional countdown timer for each game phase")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Slider(value: Binding(
                                get: { Double(settings.phaseTimer) },
                                set: { settings.phaseTimer = Int($0) }
                            ), in: 0...180, step: 15) {
                                Text("\(settings.phaseTimer)")
                            } minimumValueLabel: {
                                Text("0s")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } maximumValueLabel: {
                                Text("3m")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .accentColor(.orange)
                        }
                        
                        if settings.phaseTimer > 0 {
                            HStack {
                                Stepper("", value: Bindable(settings).phaseTimer, in: 30...180, step: 30)
                                    .labelsHidden()
                                
                                Spacer()
                                
                                Text("Exact: \(settings.phaseTimer) seconds")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section("Doctor Rules") {
                    Toggle(isOn: Bindable(settings).doctorCanSaveHimself) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Can Save Himself (Once Per Match)")
                                .font(.body)
                            Text("Doctor can choose to self-heal one time only")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle())
                    
                    Toggle(isOn: Bindable(settings).doctorCanSaveSamePersonTwice) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Can Save Same Person Twice in a Row")
                                .font(.body)
                            Text("Allows saving the same target in consecutive nights")
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
                            Text("Reset to Defaults")
                        }
                        .foregroundStyle(.orange)
                        .font(.body)
                        .fontWeight(.medium)
                    }
                } footer: {
                    Text("This will reset all settings to their safe default values.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                performReset()
            }
        } message: {
            Text("Are you sure you want to reset all settings to their default values?")
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
}

#Preview {
    SettingsView()
        .modelContainer(for: [GameSettings.self], inMemory: true)
}
