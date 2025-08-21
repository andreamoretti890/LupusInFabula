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
    var alignment: String // Keep as String for SwiftData compatibility
    var abilities: [String]
    var isUnique: Bool
    var minPlayers: Int
    var notes: String
    var emoji: String
    
    // Computed properties for type-safe access
    var roleID: RoleID {
        get { RoleID(rawValue: id) ?? .villager }
    }
    
    var roleAlignment: RoleAlignment {
        get { RoleAlignment(rawValue: alignment) ?? .villager }
        set { alignment = newValue.rawValue }
    }
    
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
    
    // Convenience initializer using enums
    convenience init(roleID: RoleID) {
        self.init(
            id: roleID.rawValue,
            name: roleID.defaultName,
            alignment: roleID.alignment.rawValue,
            abilities: roleID.defaultAbilities,
            isUnique: roleID.isUnique,
            minPlayers: roleID.minPlayers,
            notes: roleID.defaultNotes,
            emoji: roleID.defaultEmoji
        )
    }
}
