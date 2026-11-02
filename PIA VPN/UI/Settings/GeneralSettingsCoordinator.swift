//
//  GeneralSettingsCoordinator.swift
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

import Combine
import CoreArchitecture
import PIALibrary
import PIASettings
import UIKit

final class GeneralSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var host: UIViewController?
    private let resetToDefaults: @MainActor @Sendable () -> Void
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(parent: UINavigationController, resetToDefaults: @MainActor @Sendable @escaping () -> Void) {
        self.parent = parent
        self.resetToDefaults = resetToDefaults
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = GeneralSettingsView(
            dependencies: .init(
                loadPreferences: {
                    .init(
                        showsServiceMessages: AppPreferences.shared.showServiceMessages,
                        showsGeoRegions: AppPreferences.shared.showGeoServers
                    )
                },
                preferencesChanges: {
                    AsyncStream { continuation in
                        let task = Task {
                            for await _ in NotificationCenter.default.notifications(named: .PIASettingsHaveChanged) {
                                continuation.yield()
                            }
                        }
                        continuation.onTermination = { _ in task.cancel() }
                    }
                },
                setShowsServiceMessages: { AppPreferences.shared.showServiceMessages = $0 },
                setShowsGeoRegions: {
                    AppPreferences.shared.showGeoServers = $0
                    NotificationCenter.default.post(name: .PIADaemonsDidPingServers, object: nil)
                },
                resetToDefaults: resetToDefaults,
                connectSiriShortcut: { [weak self] in
                    guard let host = self?.host else { return }
                    SiriShortcutsManager.shared.presentConnectShortcut(inViewController: host)
                },
                disconnectSiriShortcut: { [weak self] in
                    guard let host = self?.host else { return }
                    SiriShortcutsManager.shared.presentDisconnectShortcut(inViewController: host)
                },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        self.host = host
        parent.pushViewController(host, animated: true)
    }
}
