//
//  ManagePlayersView.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 21/08/25.
//

import Foundation
import SwiftUI

struct ManagePlayersView: View {
    @Environment(GameService.self) private var gameService: GameService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    var body: some View {
        List {
            Section(header: Text("Selected (\(gameService.playerCount))")) {
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
                        
                        if !(gameService.playerNames.indices.contains(index) ? gameService.playerNames[index] : "").isEmpty {
                            Button(role: .destructive) {
                                gameService.setPlayerName(at: index, to: "")
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
            
            Section(header: Text("Recents")) {
                let suggestions = gameService.getNameSuggestions(prefix: searchText, limit: 50, excluding: gameService.playerNames)
                if suggestions.isEmpty {
                    Text("No recents").foregroundStyle(.secondary)
                } else {
                    ForEach(suggestions, id: \.self) { suggestion in
                        HStack {
                            Button {
                                assignSuggestion(suggestion)
                            } label: {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                    Text(suggestion)
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
                            let suggestion = suggestions[index]
                            gameService.deleteFrequentPlayer(name: suggestion)
                        }
                    }
                }
            }
        }
        .navigationTitle("Manage Players")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
        let suggestions = gameService.getNameSuggestions(prefix: "", limit: gameService.playerCount, excluding: gameService.playerNames)
        for name in suggestions {
            if configuredPlayersCount >= gameService.playerCount { break }
            assignSuggestion(name)
        }
    }
    
    private func clearAll() {
        for i in 0..<gameService.playerCount { gameService.setPlayerName(at: i, to: "") }
    }
}
