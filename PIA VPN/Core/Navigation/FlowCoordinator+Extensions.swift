//
//  FlowCoordinator+Extensions.swift
//  PIA VPN
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

extension FlowCoordinator where Output == Void {
    /// Start a coordinator that returns nothing (`Void`) and wait for it to finish.
    ///
    /// The coordinator should finish the `output` stream.
    @MainActor
    func startAsync() async {
        start()
        for await _ in output.values {}
    }
}

extension FlowCoordinator {
    /// Start a coordinator that returns something and wait for it to finish.
    ///
    /// The coordinator should emit zero or one values and finish the `output` stream.
    /// Multiple emited values are omitted and only the last one is returned, or `nil`.
    @MainActor
    func startAsync() async -> Output? {
        var res: Output?
        start()
        for await output in output.values {
            res = output
        }
        return res
    }
}
