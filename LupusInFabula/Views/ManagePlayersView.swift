//
//  ManagePlayersView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import Foundation
import SwiftUI
import Contacts

struct ManagePlayersView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var showingContactPicker: Bool = false
    @State private var contactPickerIndex: Int? = nil
    @State private var showingContactsDeniedAlert: Bool = false
    
    var body: some View {
        List {
            Section(header: Text(String(format: "manage_players.selected".localized, gameService.playerCount))) {
                ForEach(0..<gameService.playerCount, id: \.self) { index in
                    HStack(spacing: 12) {
                        Text("\(index + 1).")
                            .foregroundStyle(.secondary)
                            .frame(width: 28, alignment: .trailing)
                        TextField("player.name_format".localized(index + 1), text: Binding(
                            get: { gameService.playerNames.indices.contains(index) ? gameService.playerNames[index] : "" },
                            set: { gameService.setPlayerName(at: index, to: $0) }
                        ))
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(true)
                        .textContentType(.name)
                        // Phone field (read-only visual) and buttons
                        if gameService.playerPhones.indices.contains(index) && !gameService.playerPhones[index].isEmpty {
                            Text(gameService.playerPhones[index])
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        
                        if gameService.playerPhones.indices.contains(index) && !gameService.playerPhones[index].isEmpty {
                            Button(role: .destructive) {
                                gameService.setPlayerPhone(at: index, to: "")
                            } label: {
                                Image(systemName: "person.crop.circle.badge.xmark")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Clear phone")
                        } else {
                            Button {
                                openContacts(for: index)
                            } label: {
                                Image(systemName: "person.crop.circle.badge.plus")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Pick from contacts")
                        }
                        if !(gameService.playerNames.indices.contains(index) ? gameService.playerNames[index] : "").isEmpty {
                            Button(role: .destructive) {
                                gameService.setPlayerName(at: index, to: "")
                                if gameService.playerPhones.indices.contains(index) { gameService.setPlayerPhone(at: index, to: "") }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Clear")
                        }
                    }
                }
                
                if missingCount > 0 {
                    Button(action: autofillFromRecents) {
                        Label("Autofill from recents", systemImage: "sparkles")
                    }
                }
            }
            
            Section(header: Text("manage_players.recents".localized)) {
                let suggestions = gameService.getFrequentPlayerSuggestions(prefix: searchText, limit: 50, excluding: gameService.playerNames)
                if suggestions.isEmpty {
                    Text("manage_players.no_recents".localized).foregroundStyle(.secondary)
                } else {
                    ForEach(suggestions, id: \.id) { player in
                        HStack {
                            Button {
                                assignSuggestionWithPhone(player)
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(player.displayName)
                                        if let phone = player.phoneNumber, !phone.isEmpty {
                                            Text(phone)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "plus.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let player = suggestions[index]
                            gameService.deleteFrequentPlayer(name: player.displayName)
                        }
                    }
                }
            }
        }
        .navigationTitle("Manage Players")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerView { fullName, phone in
                if let idx = contactPickerIndex {
                    if !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        gameService.setPlayerName(at: idx, to: fullName)
                    }
                    if !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        gameService.setPlayerPhone(at: idx, to: phone)
                    }
                }
                contactPickerIndex = nil
            } onCancel: {
                contactPickerIndex = nil
            }
        }
        .alert("Contacts Access Denied", isPresented: $showingContactsDeniedAlert) {
            Button("OK", role: .cancel) {}
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable Contacts access in Settings to pick players.")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Clear All", role: .destructive) { clearAll() }
                    .disabled(configuredPlayersCount == 0)
            }
        }
    }
    
    private var configuredPlayersCount: Int {
        gameService.playerNames.prefix(gameService.playerCount).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    private var missingCount: Int { max(0, gameService.playerCount - configuredPlayersCount) }
    
    private func assignSuggestion(_ name: String) {
        if let idx = (0..<gameService.playerCount).first(where: { gameService.playerNames[$0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            gameService.setPlayerName(at: idx, to: name)
        }
    }
    
    private func autofillFromRecents() {
        let suggestions = gameService.getFrequentPlayerSuggestions(prefix: "", limit: gameService.playerCount, excluding: gameService.playerNames)
        for player in suggestions {
            if configuredPlayersCount >= gameService.playerCount { break }
            assignSuggestionWithPhone(player)
        }
    }
    
    private func assignSuggestionWithPhone(_ player: FrequentPlayer) {
        if let idx = (0..<gameService.playerCount).first(where: { gameService.playerNames[$0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) {
            gameService.setPlayerName(at: idx, to: player.displayName)
            if let phone = player.phoneNumber, !phone.isEmpty {
                gameService.setPlayerPhone(at: idx, to: phone)
            }
        }
    }
    
    private func clearAll() {
        for i in 0..<gameService.playerCount { gameService.setPlayerName(at: i, to: "") }
    }
    
    private func openContacts(for index: Int) {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            contactPickerIndex = index
            showingContactPicker = true
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        contactPickerIndex = index
                        showingContactPicker = true
                    } else {
                        showingContactsDeniedAlert = true
                    }
                }
            }
        default:
            showingContactsDeniedAlert = true
        }
    }
}
