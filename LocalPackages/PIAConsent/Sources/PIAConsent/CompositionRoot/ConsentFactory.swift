//
//  ConsentFactory.swift
//  PIAConsent
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

/// Composition root for the Consent feature. Per ADR-0006, the coordinator that calls this
/// factory owns navigation — it injects the output closures below and decides what accept and
/// reject actually do; `ConsentView`/`ConsentViewModel` hold no coordinator reference of their
/// own. "Read more" is pure in-package SwiftUI navigation (`ConsentView` presents `ReadMoreView`
/// as a sheet) and needs no closure from the caller.
public enum ConsentFactory {

    @MainActor
    public static func makeConsentView(
        onAccept: @escaping () -> Void = {},
        onReject: @escaping () -> Void = {}
    ) -> ConsentView {
        ConsentView(
            viewModel: makeConsentViewModel(
                onAccept: onAccept,
                onReject: onReject
            )
        )
    }

    public static func makeConsentViewModel(
        onAccept: @escaping () -> Void = {},
        onReject: @escaping () -> Void = {}
    ) -> ConsentViewModel {
        ConsentViewModel(onAccept: onAccept, onReject: onReject)
    }

    @MainActor
    public static func makeReadMoreView(
        onClose: @escaping () -> Void = {}
    ) -> ReadMoreView {
        ReadMoreView(viewModel: makeReadMoreViewModel(onClose: onClose))
    }

    public static func makeReadMoreViewModel(
        onClose: @escaping () -> Void = {}
    ) -> ReadMoreViewModel {
        ReadMoreViewModel(onClose: onClose)
    }
}
