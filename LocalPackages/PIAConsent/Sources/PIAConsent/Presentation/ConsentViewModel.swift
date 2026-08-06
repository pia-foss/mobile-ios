//
//  ConsentViewModel.swift
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

import Combine
import PIALocalizations

public final class ConsentViewModel: ObservableObject {
    private let onAccept: () -> Void
    private let onReject: () -> Void

    public init(
        onAccept: @escaping () -> Void = {},
        onReject: @escaping () -> Void = {}
    ) {
        self.onAccept = onAccept
        self.onReject = onReject
    }

    public func acceptButtonWasTapped() {
        onAccept()
    }

    public func noThanksButtonWasTapped() {
        onReject()
    }
}

// MARK: - Localization

extension ConsentViewModel {
    var title: String {
        L10n.Signup.Share.Data.Text.title
    }

    var message: String {
        L10n.Signup.Share.Data.Text.description
    }

    var footer: String {
        L10n.Signup.Share.Data.Text.footer
    }

    var readMoreTitle: String {
        L10n.Signup.Share.Data.Buttons.readMore
    }

    var acceptTitle: String {
        L10n.Signup.Share.Data.Buttons.accept.uppercased()
    }

    var noThanksTitle: String {
        L10n.Signup.Share.Data.Buttons.noThanks.uppercased()
    }
}
