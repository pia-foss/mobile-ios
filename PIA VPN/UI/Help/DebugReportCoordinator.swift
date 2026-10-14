//
//  DebugReportCoordinator.swift
//  PIA VPN
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

import PIADebugReport
import PIALibrary
import PIALocalizations
import UIKit

/// Drives the "Send Debug Logs" review flow: it hands the screen the live `Client` closures and
/// reports the submission result back to the user.
final class DebugReportCoordinator: ModalCoordinator<DebugReportReviewView> {

    @MainActor
    override func buildContent() -> DebugReportReviewView {
        // Debug-level entries are only sent when the user opted into debug logging.
        let includeDebug = Client.preferences.debugLogging
        return DebugReportReviewView(
            store: DebugReportReviewStore(
                initialState: .init(),
                dependencies: .live(
                    // All or nothing: the user reviews the complete report, with nothing to opt out of.
                    buildReport: {
                        await Client.buildDebugReport(
                            includeDebug: includeDebug,
                            redactIPs: true,
                            includeTunnelLog: true
                        )
                    },
                    submitReport: { report in
                        try await Client.submitDebugReport(report)
                    },
                    emit: { [weak self] output in
                        self?.handle(output)
                    }
                )
            )
        )
    }

    // MARK: Outputs

    @MainActor
    private func handle(_ output: DebugReportReview.Output) {
        switch output {
        case .didSubmit(let reportId):
            if reportId.isEmpty {
                presentResult(
                    title: L10n.Settings.ApplicationInformation.Debug.Empty.title,
                    message: L10n.Settings.ApplicationInformation.Debug.Empty.message,
                    reportId: nil
                )
            } else {
                presentResult(
                    title: L10n.Settings.ApplicationInformation.Debug.Success.title,
                    message: L10n.Settings.ApplicationInformation.Debug.Success.message(reportId),
                    reportId: reportId
                )
            }

        case .submissionFailed:
            presentResult(
                title: L10n.Settings.ApplicationInformation.Debug.Failure.title,
                message: L10n.Settings.ApplicationInformation.Debug.Failure.message,
                reportId: nil
            )
        }
    }

    @MainActor
    private func presentResult(title: String, message: String, reportId: String?) {
        let alert = Macros.alert(title, message)
        if let reportId, !reportId.isEmpty {
            alert.addActionWithTitle(L10n.Settings.ApplicationInformation.Debug.Success.copyId) { [weak self] in
                UIPasteboard.general.string = reportId
                self?.dismissFlow()
            }
        }
        alert.addCancelActionWithTitle(L10n.Global.close) { [weak self] in
            self?.dismissFlow()
        }
        topPresentedViewController?.present(alert, animated: true)
    }

    @MainActor
    private func dismissFlow() {
        topPresentedViewController?.dismiss(animated: true)
    }

    /// The topmost presented controller, which is where the result alert belongs. Falls back to the
    /// presenter when nothing has been presented yet.
    @MainActor
    private var topPresentedViewController: UIViewController? {
        var top = presenter
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
