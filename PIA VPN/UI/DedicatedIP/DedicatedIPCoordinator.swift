//
//  DedicatedIPCoordinator.swift
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
import PIADedicatedIP
import PIALibrary
import UIKit

/// Presents the Dedicated IP screen modally and turns its outputs into banners, notifications and
/// logout.
final class DedicatedIPCoordinator: FlowCoordinator {

    enum Output {
        case didFinish
    }

    private let presenter: UIViewController
    private let subject = PassthroughSubject<Output, Never>()

    var output: AnyPublisher<Output, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    // MARK: FlowCoordinator

    func start() {
        MainActor.assumeIsolated {
            let store = DedicatedIPStore(
                dependencies: .live(
                    getDedicatedIp: DedicatedIPFactory.makeGetDedicatedIpUseCase(),
                    activateDIPToken: DedicatedIPFactory.makeActivateDIPTokenUseCase(),
                    removeDIPToken: DedicatedIPFactory.makeRemoveDIPUseCase(),
                    emit: { [weak self] in self?.handle($0) }
                )
            )
            let host = AutolayoutHostingController(rootView: DedicatedIPView(store: store))
            host.onDismiss = { [weak self] in self?.subject.send(.didFinish) }
            ModalNavigationSegue.configureAndPresent(modal: host, from: presenter)
        }
    }

    // MARK: Outputs

    @MainActor
    private func handle(_ output: DedicatedIP.Output) {
        switch output {
        case .showNote(let note):
            show(note)
        case .didChange:
            Macros.postNotification(.PIAThemeDidChange)
        case .unauthorized:
            Client.providers.accountProvider.logout(nil)
            Macros.postNotification(.PIAUnauthorized)
        }
    }

    @MainActor
    private func show(_ note: DedicatedIP.Note) {
        let image = Asset.iconWarning.image
        switch note.kind {
        case .success:
            Macros.displaySuccessImageNote(withImage: image, message: note.message)
        case .sticky:
            Macros.displayStickyNote(withMessage: note.message, andImage: image)
        case .timed(let duration):
            Macros.displayImageNote(withImage: image, message: note.message, andDuration: duration)
        }
    }
}
