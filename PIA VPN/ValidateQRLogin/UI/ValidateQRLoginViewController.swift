//
//  ValidateQRLoginViewController.swift
//  PIA VPN
//
//  Created by Said Rehouni on 18/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import PIAAssetsMobile
import PIALibrary
import PIALocalizations
import UIKit

final class ValidateQRLoginViewController: AutolayoutViewController {
    @IBOutlet weak var piaLogoImageView: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    var validateQRLogin: ValidateQRLoginUseCaseType!
    var cancelQRLogin: CancelQRLoginUseCaseType!

    override func viewDidLoad() {
        super.viewDidLoad()

        assert(validateQRLogin != nil, "ValidateQRLoginUseCaseType not set in ValidateQRLoginViewController")
        assert(cancelQRLogin != nil, "CancelQRLoginUseCaseType not set in ValidateQRLoginViewController")

        piaLogoImageView.image = Asset.navLogo.image
        loadingSpinner.style = .large
        loadingSpinner.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestConfirmation()
    }

    private func requestConfirmation() {
        let alert = Macros.alertController(L10n.Validateqr.Confirmation.title, L10n.Validateqr.Confirmation.message)
        alert.addDefaultAction(L10n.Validateqr.Confirmation.continue) { [weak self] in
            self?.performValidateLogin()
        }
        alert.addCancelAction(L10n.Global.cancel) { [weak self] in
            self?.cancelQRLogin()
            self?.dismiss(animated: true)
        }
        present(alert, animated: true)
    }

    private func performValidateLogin() {
        validateQRLogin { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.dismiss(animated: true)
                case .failure:
                    self?.presentError()
                }
            }
        }
    }

    private func presentError() {
        let alert = Macros.alert(
            L10n.ErrorAlert.ConnectionError.NoNetwork.title,
            L10n.ErrorAlert.ConnectionError.NoNetwork.message
        )

        alert.addActionWithTitle(L10n.Global.ok) { [weak self] in
            self?.dismiss(animated: true)
        }

        present(alert, animated: true, completion: nil)
    }
}
