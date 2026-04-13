/*
 *  Copyright (c) 2023 Private Internet Access, Inc.
 *
 *  This file is part of the Private Internet Access Mobile Client.
 *
 *  The Private Internet Access Mobile Client is free software: you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License as published by the Free
 *  Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 *  The Private Internet Access Mobile Client is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 *  details.
 *
 *  You should have received a copy of the GNU General Public License along with the Private
 *  Internet Access Mobile Client.  If not, see <https://www.gnu.org/licenses/>.
 */

import Foundation

public struct ShadowsocksRegionsResponse: Codable, Sendable {
    public var iso: String
    public var region: String
    public var host: String
    public var port: Int
    public var key: String
    public var cipher: String

    public init(
        iso: String = "world",
        region: String,
        host: String,
        port: Int,
        key: String,
        cipher: String
    ) {
        self.iso = iso
        self.region = region
        self.host = host
        self.port = port
        self.key = key
        self.cipher = cipher
    }
}
