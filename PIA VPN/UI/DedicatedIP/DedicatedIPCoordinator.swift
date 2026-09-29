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

import PIAAssetsMobile
import PIADedicatedIP
import PIALibrary

final class DedicatedIPCoordinator: ModalCoordinator<DedicatedIPView> {
    @MainActor
    override func buildContent() -> DedicatedIPView {
        let store = DedicatedIPStore(
            dependencies: .live(
                getDedicatedIp: DedicatedIPFactory.makeGetDedicatedIpUseCase(),
                activateDIPToken: DedicatedIPFactory.makeActivateDIPTokenUseCase(),
                removeDIPToken: DedicatedIPFactory.makeRemoveDIPUseCase(),
                emit: { [weak self] in self?.handle($0) }
            )
        )
        return DedicatedIPView(store: store)
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
