//
//  DebugReportReviewStore.swift
//  PIADebugReport
//
//  Copyright © 2026 Private Internet Access, Inc.
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

/// The screen's store, which is `CoreArchitecture.Store` with this feature's types filled in.
public typealias DebugReportReviewStore = Store<DebugReportReview.State, DebugReportReview.Action>

extension DebugReportReviewStore {
    public convenience init(
        initialState: DebugReportReview.State,
        dependencies: DebugReportReview.Dependencies
    ) {
        self.init(
            initial: initialState,
            reduce: DebugReportReview.Reducer(dependencies: dependencies).reduce
        )
    }
}
