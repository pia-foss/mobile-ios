//
//  GetStartedHostingController.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 07.01.26.
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
import Combine
import PIALibrary

private let log = PIALogger.logger(for: GetStartedHostingController.self)

final class GetStartedHostingController: UIHostingController<GetStartedView<GetStartedViewModel>> {
    private var cancellables = Set<AnyCancellable>()
    private let viewModel: GetStartedViewModel

    init(viewModel: GetStartedViewModel) {
        self.viewModel = viewModel
        super.init(rootView: GetStartedView(viewModel: viewModel))

        setupEventHandlers()
        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupObservers() {
        NotificationCenter
            .default
            .publisher(for: .PIARecoverAccount)
            .sink(receiveValue: recoverAccount)
            .store(in: &cancellables)

        NotificationCenter
            .default
            .publisher(for: .PIAFinishLoginWithMagicLink)
            .sink(receiveValue: finishLoginWithMagicLink)
            .store(in: &cancellables)
    }

    private func recoverAccount(_ notification: Notification? = nil) {
        let restoreVC = StoryboardScene.Welcome.restoreSignupViewController.instantiate()
        // TODO: Configure
        navigationController?.pushViewController(restoreVC, animated: true)
    }

    private func finishLoginWithMagicLink(_ notification: Notification) {
        if let userInfo = notification.userInfo, let _ = userInfo[NotificationKey.error] as? Error {
            Macros.displayImageNote(
                withImage: Asset.Images.iconWarning.image,
                message: L10n.Welcome.Purchase.Error.Connectivity.title,
                accessbilityIdentifier: Accessibility.Id.Login.Error.banner
            )
            return
        }

        // TODO: Handle login
    }

    // MARK: - SwiftUI/UIKit messaging integration

    private func setupEventHandlers() {
        viewModel.events
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: handleEvent)
            .store(in: &cancellables)
    }
    
    private func handleEvent(_ event: GetStartedViewEvent) {
        switch event {
        case .navigateToLogin:
            navigateToLogin()
        case .showUncreditedAlert:
            showUncreditedAlert()
        case .showPurchaseErrorAlert(let error):
            showPurchaseErrorAlert(error)
        case .showLoading(let isLoading):
            showLoading(isLoading)
        case .completePurchase(let signupEmail, let signupTransaction):
            // TODO: completePurchase
            break
        }
    }

    // MARK: - Navigation

    private func navigateToLogin() {
        let loginVC = StoryboardScene.Welcome.loginViewController.instantiate()
        // TODO: Pass preset
        // loginVC.preset = preset
        navigationController?.pushViewController(loginVC, animated: true)
    }

    private func showUncreditedAlert() {
        let alert = Macros.alert(nil, L10n.Signup.Purchase.Uncredited.Alert.message)
        alert.addCancelAction(L10n.Signup.Purchase.Uncredited.Alert.Button.cancel)
        alert.addActionWithTitle(L10n.Signup.Purchase.Uncredited.Alert.Button.recover) {
            self.navigationController?.popToRootViewController(animated: true)
            self.recoverAccount()
        }
        present(alert, animated: true, completion: nil)
    }

    private func showPurchaseErrorAlert(_ error: Error) {
        let message = error.localizedDescription
        Macros.displayImageNote(
            withImage: Asset.Images.iconWarning.image,
            message: message
        )
    }

    private func showLoading(_ isLoading: Bool) {
        // TODO: Display/hide loading animation
        if isLoading {
            // showLoadingAnimation()
        } else {
            // hideLoadingAnimation()
        }
    }
}
