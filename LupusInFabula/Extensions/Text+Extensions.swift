//
//  Text+Extensions.swift
//  LupusInFabula
//
//  Created by Andrea Moretti on 19/08/25.
//

import SwiftUI

extension Text {
    init(_ text: String, countToInflect: Int) {
        if countToInflect == 1 {
            self.init("^[\(text)](morphology: { number: \"one\" }, inflect: true)")
        } else {
            self.init("^[\(text)](morphology: { number: \"other\" }, inflect: true)")
        }
    }
}
