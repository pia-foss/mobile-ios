//
//  About+Reducer.swift
//  PIAAbout
//
//  Copyright © 2026 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

import CoreArchitecture
import Foundation

extension About {
    struct Reducer {
        let dependencies: Dependencies

        func reduce(_ state: inout State, _ action: Action) -> Effect<Action>? {
            switch action {
            case .onAppear:
                guard state.components == nil else { return nil }
                return .task { [dependencies] in .componentsLoaded(dependencies.loadComponents()) }

            case .componentsLoaded(let components):
                state.components = components
                return .merge(
                    components.licenses.map { license in
                        .task { [dependencies] in
                            .licenseLoaded(name: license.name, text: await dependencies.fetchLicense(license.licenseURL))
                        }
                    }
                )

            case .licenseLoaded(let name, let text):
                if let text {
                    state.licenseTexts[name] = text
                } else {
                    state.unavailableLicenses.insert(name)
                }
                return nil
            }
        }
    }
}
