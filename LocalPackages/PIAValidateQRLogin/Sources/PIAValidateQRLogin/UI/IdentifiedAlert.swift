//
//  IdentifiedAlert.swift
//  PIAValidateQRLogin
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

import SwiftUI
import UIKit

/// A system alert whose buttons carry accessibility identifiers.
///
/// SwiftUI's `.alert` drops `accessibilityIdentifier` on its buttons, so UI tests
/// can only find them by label. Present one with `View.identifiedAlert(_:)`.
struct IdentifiedAlert {
    /// One alert button; `identifier` is what UI tests query.
    struct Action {
        let title: String
        var style: UIAlertAction.Style = .default
        let identifier: String
        let handler: @MainActor () -> Void
    }

    let title: String
    let message: String
    let actions: [Action]
}

extension View {
    // Shows `alert` while it's non-nil and dismisses it when it becomes nil.
    func identifiedAlert(_ alert: IdentifiedAlert?) -> some View {
        background(IdentifiedAlertPresenter(alert: alert))
    }
}

/// Hosts an invisible view controller that presents the alert, since SwiftUI has no UIKit presentation hook.
private struct IdentifiedAlertPresenter: UIViewControllerRepresentable {
    let alert: IdentifiedAlert?

    func makeUIViewController(context: Context) -> IdentifiedAlertViewController {
        IdentifiedAlertViewController()
    }

    func updateUIViewController(_ controller: IdentifiedAlertViewController, context: Context) {
        controller.alert = alert
    }
}

/// Keeps the presented `UIAlertController` in step with `alert`: presents it once
/// the view is in a window, keeps it while `alert` is set, and dismisses it when cleared.
private final class IdentifiedAlertViewController: UIViewController {
    var alert: IdentifiedAlert? {
        didSet { sync() }
    }

    private weak var shownAlert: UIAlertController?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sync()
    }

    private func sync() {
        // UIKit dismisses the alert on tap before calling the handler, so a follow-up alert can be presented.
        if let shownAlert, shownAlert.presentingViewController != nil {
            if alert == nil { shownAlert.dismiss(animated: true) }
            return
        }
        // Off-window presentation fails; viewDidAppear retries.
        guard let alert, viewIfLoaded?.window != nil else { return }

        let controller = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        for action in alert.actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in action.handler() }
            // UIAlertAction has no public identifier API; XCUITest reads this key.
            alertAction.setValue(action.identifier, forKey: "accessibilityIdentifier")
            controller.addAction(alertAction)
        }
        shownAlert = controller
        present(controller, animated: true)
    }
}
