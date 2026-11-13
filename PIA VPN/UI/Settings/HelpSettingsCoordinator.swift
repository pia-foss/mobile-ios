//
//  HelpSettingsCoordinator.swift
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

private let log = PIALogger.logger(for: HelpSettingsCoordinator.self)

final class HelpSettingsCoordinator: @MainActor FlowCoordinator {
    private weak var parent: UINavigationController?
    private weak var host: UIViewController?
    private weak var pendingPreferences: Client.Preferences.Editable?
    private let subject = PassthroughSubject<Void, Never>()

    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(parent: UINavigationController, pendingPreferences: Client.Preferences.Editable) {
        self.parent = parent
        self.pendingPreferences = pendingPreferences
    }

    @MainActor
    func start() {
        guard let parent else {
            subject.send(completion: .finished)
            return
        }

        let view = HelpSettingsView(
            initialState: .init(
                preferences: .init(
                    debugLogging: pendingPreferences?.debugLogging ?? false,
                    sharesServiceQualityData: pendingPreferences?.shareServiceQualityData ?? false
                ),
                version: Macros.localizedVersionFullString() ?? "",
                isDebugLoggingEditable: Self.isDebugLoggingEditable
            ),
            dependencies: .init(
                setDebugLogging: { [weak self] in self?.pendingPreferences?.debugLogging = $0 },
                clearLogs: { PIALogHandler.logStorage.clear() },
                setSharesServiceQualityData: { [weak self] in self?.setSharesServiceQualityData($0) },
                submitDebugReport: { try await Self.submitDebugReport() },
                copyToPasteboard: { UIPasteboard.general.string = $0 },
                showServiceQualityInformation: { [weak self] in self?.showServiceQualityInformation() },
                showServiceQualityEvents: { [weak self] in self?.showServiceQualityEvents() },
                showLatestNews: { [weak self] in self?.showLatestNews() },
            )
        )
        let host = NavigationHostingController(rootView: view) { [subject] in
            subject.send(completion: .finished)
        }
        self.host = host
        parent.pushViewController(host, animated: true)
    }

    // Bootstrapper forces debug logging on for Debug and Staging builds
    private static var isDebugLoggingEditable: Bool {
        #if DEBUG || STAGING
            false
        #else
            true
        #endif
    }

    private static func submitDebugReport() async throws -> String {
        do {
            let id = try await Client.submitDebugReport()
            if id.isEmpty {
                log.warning("CSI report ID was empty")
            }
            return id
        } catch {
            log.error("Failed to submit debug report: \(error)")
            throw error
        }
    }

    @MainActor
    private func setSharesServiceQualityData(_ isOn: Bool) {
        guard let pendingPreferences else { return }
        pendingPreferences.shareServiceQualityData = isOn
        if isOn {
            pendingPreferences.versionWhenServiceQualityOpted = Macros.versionString()
            ServiceQualityManager.shared.start()
        } else {
            pendingPreferences.versionWhenServiceQualityOpted = nil
            ServiceQualityManager.shared.stop()
        }
    }

    @MainActor
    private func showServiceQualityInformation() {
        guard let host else { return }
        let coordinator = ShareDataInformationCoordinator(presenter: host)
        Task {
            await coordinator.startAsync()
        }
    }

    @MainActor
    private func showServiceQualityEvents() {
        guard let parent else { return }
        let view = ServiceQualityEventsView {
            await withCheckedContinuation { continuation in
                ServiceQualityManager.shared.availableData { continuation.resume(returning: $0) }
            }
        }
        parent.pushViewController(NavigationHostingController(rootView: view) {}, animated: true)
    }

    @MainActor
    private func showLatestNews() {
        let cards = CardFactory.getAllCards()
        guard let host, !cards.isEmpty,
            let cardsController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "PIACardsViewController") as? PIACardsViewController
        else { return }
        cardsController.setupWith(cards: cards)
        cardsController.modalPresentationStyle = .overCurrentContext
        host.present(cardsController, animated: true)
    }
}
