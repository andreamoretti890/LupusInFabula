//
//  String+Localization.swift
//  LupusInFabula
//
//  Created for String Catalog Localization
//

import Foundation
import SwiftUI

extension String {
    /// Convenience method for localized strings using the default Localizable table
    /// - Returns: Localized string from Localizable.xcstrings
    var localized: String {
        String(localized: String.LocalizationValue(self))
    }
    
    /// Convenience method for localized strings with arguments
    /// - Parameter arguments: Arguments to interpolate into the localized string
    /// - Returns: Localized string with interpolated arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

extension Text {
    /// Convenience initializer for localized Text views
    /// - Parameter key: The localization key
    /// - Returns: Text view with localized content
    init(localized key: String) {
        self.init(key)
    }
}
