//
//  ValidateQRLoginViewController.swift
//  PIA VPN
//
//  Created by Said Rehouni on 18/3/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import UIKit
import PIALibrary

class ValidateQRLoginViewController: AutolayoutViewController {
    @IBOutlet weak var piaLogoImageView: UIImageView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    var validateQRLogin: ValidateQRLoginUseCaseType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setImageforMode(isLightMode: traitCollection.userInterfaceStyle == .light)
        loadingSpinner.style = .large
        loadingSpinner.startAnimating()
        
        validateQRLogin? { result in
            DispatchQueue.main.async { [self] in
                switch result {
                    case .success:
                        dismiss(animated: true)
                    case .failure:
                        presentError()
                }
            }
        }
    }
    
    private func presentError() {
        let alert = Macros.alert(
            L10n.Localizable.ErrorAlert.ConnectionError.NoNetwork.title,
            L10n.Localizable.ErrorAlert.ConnectionError.NoNetwork.message
        )

        alert.addActionWithTitle(L10n.Localizable.Global.ok) {
            self.dismiss(animated: true)
        }

        present(alert, animated: true, completion: nil)
    }
    
    private func setImageforMode(isLightMode: Bool) {
        piaLogoImageView.image = isLightMode ? UIImage(named: "nav-logo") 
        : UIImage(named: "nav-logo-white")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setImageforMode(isLightMode: traitCollection.userInterfaceStyle == .light)
    }
}
