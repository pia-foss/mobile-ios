//
//  PIACSILastKnownExceptionProvider.swift
//  PIALibrary
//
//  Created by Waleed Mahmood on 13.05.22.
//

import Foundation
import PIACSI

struct PIACSILastKnownExceptionProvider: CSIDataProvider {
    var sectionName: String { "last_known_exception" }
    var content: String? { Client.preferences.lastKnownException }
}
