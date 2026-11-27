//
//  AutomationSettingsCoordinator.swift
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

final class AutomationSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private var childCoordinator: TrustedNetworksSettingsCoordinator?
    private var cancellables = Set<AnyCancellable>()
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(
        parent: UINavigationController,
        pendingPreferences: Client.Preferences.Editable
    ) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = AutomationSettingsView(
            dependencies: .init(
                isAutomationEnabled: { Client.preferences.nmtRulesEnabled },
                preferencesChanges: { NotificationCenter.default.signals(named: .PIASettingsHaveChanged) },
                setAutomationEnabled: { [weak self] in self?.setAutomationEnabled($0) },
                isKillSwitchEnabled: { [weak self] in self?.pendingPreferences?.isPersistentConnection ?? Client.preferences.isPersistentConnection },
                enableAutomationWithKillSwitch: { [weak self] in self?.enableAutomationWithKillSwitch() },
                showManageAutomation: { [weak self] in self?.showManageAutomation() },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func setAutomationEnabled(_ isOn: Bool) {
        let preferences = Client.preferences.editable()
        preferences.nmtRulesEnabled = isOn
        preferences.commit()
    }

    /// Commits the kill switch together with Automation, like the dashboard does, so they are never persisted apart.
    /// Deferring the kill switch to the Settings commit would lose it if that commit is cancelled (the "must disconnect"
    /// alert) or never runs. The pending preferences mirror it so the Settings commit doesn't turn it back off.
    /// Reconnect notifications follow the kill switch, as on the Privacy Features screen.
    @MainActor
    private func enableAutomationWithKillSwitch() {
        let preferences = Client.preferences.editable()
        preferences.isPersistentConnection = true
        preferences.showReconnectNotifications = true
        preferences.nmtRulesEnabled = true
        preferences.commit()

        pendingPreferences?.isPersistentConnection = true
        pendingPreferences?.showReconnectNotifications = true
    }

    @MainActor
    private func showManageAutomation() {
        guard let parent, let pendingPreferences else { return }
        cancellables.removeAll()
        let coordinator = TrustedNetworksSettingsCoordinator(parent: parent, pendingPreferences: pendingPreferences)
        childCoordinator = coordinator
        coordinator.output
            .sink(
                receiveCompletion: { [weak self] _ in self?.childCoordinator = nil },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        coordinator.start()
    }
}
