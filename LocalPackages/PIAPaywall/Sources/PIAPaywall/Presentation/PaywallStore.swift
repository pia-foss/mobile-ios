//
//  PaywallStore.swift
//  PIAPaywall
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

/// The paywall's store, which is `CoreArchitecture.Store` with this feature's types filled in.
///
/// Named so that hosts never write the generic parameters, and so that nothing outside this package
/// has to import `CoreArchitecture` to hold one.
public typealias PaywallStore = Store<Paywall.State, Paywall.Action>

extension Store where State == Paywall.State, Action == Paywall.Action {

    /// Creates the paywall's store, wiring the reducer to `dependencies`.
    public convenience init(
        initialState: Paywall.State = Paywall.State(),
        dependencies: Paywall.Dependencies
    ) {
        self.init(initial: initialState, reduce: Paywall.Reducer(dependencies: dependencies).reduce)
    }
}
