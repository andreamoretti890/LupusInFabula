//
//  SavedConfig.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 18/08/25.
//

import Foundation
import SwiftData

@Model
final class SavedConfig {
    @Attribute(.unique) var id: String
    var date: Date
    var playersCount: Int
    var roleSelection: [RoleCount]
    var presetID: String?
    
    init(id: String, date: Date, playersCount: Int, roleSelection: [RoleCount], presetID: String? = nil) {
        self.id = id
        self.date = date
        self.playersCount = playersCount
        self.roleSelection = roleSelection
        self.presetID = presetID
    }
}
