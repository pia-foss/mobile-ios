//
//  Product.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 11/04/2019.
//  Copyright © 2020 Private Internet Access, Inc.
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

public struct Product: Codable {
    
    public let identifier: String
    
    public let plan: Plan
    
    public let price: String
    
    public let legacy: Bool
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case plan = "plan"
        case price = "price"
        case legacy = "legacy"
    }
    
}
