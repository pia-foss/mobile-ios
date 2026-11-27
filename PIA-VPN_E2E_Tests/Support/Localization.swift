//
//  Localization.swift
//  PIA-VPN_E2E_Tests
//
//  Created by Geneva Parayno on 24/10/23.
//  Copyright © 2023 Private Internet Access Inc. All rights reserved.
//

import PIALocalizations
import XCTest

/// The app's English strings. `BaseTest` launches the app in English, but the test runner keeps the device language,
/// so the lookup is pinned to English for labels to match on any device language.
private let englishStrings: Bundle = {
    guard let path = Bundle.piaLocalizations.path(forResource: "en", ofType: "lproj"), let bundle = Bundle(path: path) else {
        fatalError("PIALocalizations has no en.lproj")
    }
    return bundle
}()

extension XCUIApplication {
    func getString(key: String, comment: String) -> String {
        englishStrings.localizedString(forKey: key, value: nil, table: nil)
    }
}
