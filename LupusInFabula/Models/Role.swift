//
//  Role.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData

@Model
final class Role {
    @Attribute(.unique) var id: String
    var name: String
    var alignment: String // "Villager", "Werewolf", "Special"
    var abilities: [String]
    var isUnique: Bool
    var minPlayers: Int
    var notes: String
    var emoji: String
    
    init(id: String, name: String, alignment: String, abilities: [String], isUnique: Bool, minPlayers: Int, notes: String, emoji: String) {
        self.id = id
        self.name = name
        self.alignment = alignment
        self.abilities = abilities
        self.isUnique = isUnique
        self.minPlayers = minPlayers
        self.notes = notes
        self.emoji = emoji
    }
}
