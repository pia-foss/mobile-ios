//
//  PrivacyFeaturesSettingsCoordinator.swift
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
import SafariServices
import SwiftUI
import UIKit

private let log = PIALogger.logger(for: PrivacyFeaturesSettingsCoordinator.self)

final class PrivacyFeaturesSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var host: UIViewController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private weak var settingsDelegate: SettingsDelegate?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(
        parent: UINavigationController,
        pendingPreferences: Client.Preferences.Editable,
        settingsDelegate: SettingsDelegate
    ) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
        self.settingsDelegate = settingsDelegate
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = PrivacyFeaturesSettingsView(
            dependencies: .init(
                loadPreferences: { [weak self] in self?.preferences() ?? .init(killSwitch: false, reconnectNotifications: false) },
                isAutomationEnabled: { Client.preferences.nmtRulesEnabled },
                preferencesChanges: { NotificationCenter.default.signals(named: .PIASettingsHaveChanged) },
                savePreferences: { [weak self] in self?.save($0) },
                isContentBlockerEnabled: { await Self.isContentBlockerEnabled() },
                appDidBecomeActive: { NotificationCenter.default.signals(named: UIApplication.didBecomeActiveNotification) },
                reloadContentBlocker: { await Self.reloadContentBlocker() },
                showContentBlockerTutorial: { [weak self] in self?.showContentBlockerTutorial() },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        self.host = host
        parent.pushViewController(host, animated: true)
    }

    @MainActor
    private func preferences() -> PrivacyFeaturesSettings.Preferences? {
        guard let pendingPreferences else { return nil }
        return .init(
            killSwitch: pendingPreferences.isPersistentConnection,
            reconnectNotifications: pendingPreferences.showReconnectNotifications
        )
    }

    @MainActor
    private func save(_ preferences: PrivacyFeaturesSettings.Preferences) {
        guard let pendingPreferences else { return }
        pendingPreferences.isPersistentConnection = preferences.killSwitch
        pendingPreferences.showReconnectNotifications = preferences.reconnectNotifications
        settingsDelegate?.refreshSettings()
        settingsDelegate?.reportUpdatedPreferences()
    }

    @MainActor
    private func showContentBlockerTutorial() {
        guard let host else { return }
        let tutorial = UIHostingController(
            rootView: ContentBlockerTutorialView { [weak host] in
                host?.dismiss(animated: true)
            })
        tutorial.isModalInPresentation = true
        host.present(tutorial, animated: true)
    }

    private static func isContentBlockerEnabled() async -> Bool {
        do {
            return
                try await SFContentBlockerManager
                .stateOfContentBlocker(withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier)
                .isEnabled
        } catch {
            log.error("Could not read Safari Content Blocker state: \(error)")
            return false
        }
    }

    private static func reloadContentBlocker() async {
        do {
            try await SFContentBlockerManager.reloadContentBlocker(
                withIdentifier: AppConstants.Extensions.adBlockerBundleIdentifier
            )
        } catch {
            log.error("Could not reload Safari Content Blocker: \(error)")
        }
    }
}
