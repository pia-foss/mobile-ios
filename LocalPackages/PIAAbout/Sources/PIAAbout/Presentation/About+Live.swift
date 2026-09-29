//
//  About+Live.swift
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

import Foundation

extension About.Dependencies {
    public static var live: Self {
        .init(
            loadComponents: {
                guard let url = Bundle.module.url(forResource: "Components", withExtension: "plist"),
                    let data = try? Data(contentsOf: url),
                    let components = try? PropertyListDecoder().decode(AboutComponents.self, from: data)
                else {
                    return AboutComponents(notices: [], licenses: [])
                }
                return components
            },
            fetchLicense: { url in
                guard let (data, response) = try? await URLSession.shared.data(from: url),
                    let status = (response as? HTTPURLResponse)?.statusCode, (200..<300).contains(status)
                else {
                    return nil
                }
                return String(decoding: data, as: UTF8.self)
            }
        )
    }
}
