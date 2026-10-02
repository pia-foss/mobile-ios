//
//  ModalCoordinator.swift
//  PIA VPN
//
//  Created by Mario on 29/09/2026.
//  Copyright © 2026 Private Internet Access Inc. All rights reserved.
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
import PIASwiftUI
import SwiftUI

class ModalCoordinator<Content: ViewWithTitle>: @MainActor FlowCoordinator {
    internal weak var presenter: UIViewController?
    internal let subject = PassthroughSubject<Void, Never>()
    var output: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    init(presenter: UIViewController) {
        self.presenter = presenter
    }

    @MainActor
    func buildContent() -> Content {
        fatalError("not implemented")
    }

    @MainActor
    func start() {
        let content = buildContent()
        let host = AutolayoutHostingController(rootView: content) { [weak self] in
            self?.subject.send(completion: .finished)
        }

        guard let presenter else {
            subject.send(completion: .finished)
            return
        }

        ModalNavigationSegue.configureAndPresent(modal: host, from: presenter)
    }
}
