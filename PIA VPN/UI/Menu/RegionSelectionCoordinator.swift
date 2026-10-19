//
//  RegionSelectionCoordinator.swift
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
import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import PIARegionList
import UIKit

/// Presents the region list and outputs the server the user picked, once dismissed.
final class RegionSelectionCoordinator: @MainActor FlowCoordinator {
    private weak var presenter: UIViewController?
    private weak var host: RegionListHostingController?
    private let animated: Bool
    private let subject = PassthroughSubject<Server, Never>()

    var output: AnyPublisher<Server, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController, animated: Bool) {
        self.presenter = presenter
        self.animated = animated
    }

    @MainActor
    func start() {
        guard let presenter else {
            subject.send(completion: .finished)
            return
        }
        Server.migrateLegacyDIPFavorites()

        let store = RegionListStore(
            dependencies: .live(
                preferences: .app,
                favorites: RegionsSelectionFactory.makeFavoriteRegionUseCase,
                progressResetDelay: AppConfiguration.Animations.duration,
                emit: { [weak self] in self?.handle($0) }
            )
        )
        let host = RegionListHostingController(store: store) { [weak self] in
            self?.subject.send(completion: .finished)
        }
        self.host = host
        ModalNavigationSegue.configureAndPresent(modal: host, from: presenter, animated: animated)
    }

    @MainActor
    private func handle(_ output: RegionList.Output) {
        switch output {
        case .selected(let id):
            TransientState.shouldDisplayRegionPicker = false
            let server = Self.server(for: id)
            host?.dismissModal { [weak self] in
                server.map { self?.subject.send($0) }
            }
        case .dismiss:
            TransientState.shouldDisplayRegionPicker = false
            host?.dismissModal()
        case .refreshUnavailableWhileConnected:
            Macros.displayImageNote(withImage: Asset.iconWarning.image, message: L10n.Region.Refresh.Connected.error)
        }
    }

    private static func server(for id: RegionList.ID) -> Server? {
        if id == .automatic {
            return .automatic
        }
        let serverProvider = Client.providers.serverProvider
        let dipTokens = serverProvider.dipTokens ?? []
        return serverProvider.currentServers.first { server in
            guard server.identifier == id.identifier else { return false }
            guard let dipToken = server.dipToken else { return !id.isDedicated }
            return id.isDedicated && dipTokens.contains(dipToken)
        }
    }
}

extension RegionList.Preferences {
    static let app = RegionList.Preferences(
        selectedID: {
            let server = Client.preferences.displayedServer
            return server.isAutomatic ? .automatic : RegionList.ID(identifier: server.identifier, isDedicated: server.dipToken != nil)
        },
        sort: { AppPreferences.shared.regionFilter },
        setSort: { AppPreferences.shared.regionFilter = $0 },
        showGeoServers: { AppPreferences.shared.showGeoServers }
    )
}
