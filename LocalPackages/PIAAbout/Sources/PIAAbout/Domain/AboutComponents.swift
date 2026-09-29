//
//  AboutComponents.swift
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

public struct AboutComponents: Decodable, Equatable, Sendable {
    public struct Notice: Decodable, Equatable, Sendable {
        public let name: String
        public let copyright: String
        public let notice: String

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case copyright = "Copyright"
            case notice = "Notice"
        }
    }

    public struct License: Decodable, Equatable, Sendable {
        public let name: String
        public let copyright: String
        public let licenseURL: URL

        enum CodingKeys: String, CodingKey {
            case name = "Name"
            case copyright = "Copyright"
            case licenseURL = "LicenseURL"
        }
    }

    public let notices: [Notice]
    public let licenses: [License]

    enum CodingKeys: String, CodingKey {
        case notices = "Notices"
        case licenses = "Licenses"
    }
}

extension AboutComponents.License {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        copyright = try container.decode(String.self, forKey: .copyright)
        let urlString = try container.decode(String.self, forKey: .licenseURL)
        guard let url = URL(string: urlString) else {
            throw DecodingError.dataCorruptedError(forKey: .licenseURL, in: container, debugDescription: "Invalid URL")
        }
        licenseURL = url
    }
}
