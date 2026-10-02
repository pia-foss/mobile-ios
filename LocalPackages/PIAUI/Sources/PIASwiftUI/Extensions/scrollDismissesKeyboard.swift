//
//  scrollDismissesKeyboard.swift
//  PIAUI
//
//  Created by Mario on 01/05/2026.
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

import SwiftUI

@available(iOS, deprecated: 16, renamed: "ScrollDismissesKeyboardMode")
public enum ScrollDismissesKeyboardModeLegacy {
    case automatic
    case immediately
    case interactively
    case never

    @available(iOS 16.0, *)
    var mode: ScrollDismissesKeyboardMode {
        return switch self {
        case .automatic: .automatic
        case .immediately: .immediately
        case .interactively: .interactively
        case .never: .never
        }
    }
}

public extension View {
    @available(iOS, deprecated: 16, renamed: "scrollDismissesKeyboard")
    func scrollDismissesKeyboard(_ mode: ScrollDismissesKeyboardModeLegacy) -> some View {
        if #available(iOS 16.0, *) {
            return scrollDismissesKeyboard(mode.mode)
        } else {
            return self
        }
    }
}
