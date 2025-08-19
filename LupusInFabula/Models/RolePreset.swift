//
//  RolePreset.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData

@Model
final class RolePreset {
    @Attribute(.unique) var id: String
    var name: String
    var roleCounts: [RoleCount]
    var minPlayers: Int
    var maxPlayers: Int
    var presetDescription: String
    
    init(id: String, name: String, roleCounts: [RoleCount], minPlayers: Int, maxPlayers: Int, presetDescription: String) {
        self.id = id
        self.name = name
        self.roleCounts = roleCounts
        self.minPlayers = minPlayers
        self.maxPlayers = maxPlayers
        self.presetDescription = presetDescription
    }
}

struct RoleCount: Codable {
    var roleID: String
    var count: Int
    
    init(roleID: String, count: Int) {
        self.roleID = roleID
        self.count = count
    }
    
    // Convenience initializer using enum
    init(roleID: RoleID, count: Int) {
        self.roleID = roleID.rawValue
        self.count = count
    }
    
    // Computed property for type-safe access
    var role: RoleID? {
        return RoleID(rawValue: roleID)
    }
}
