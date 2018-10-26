//
//  GetStartedViewController.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 26/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

public class GetStartedViewController: AutolayoutViewController, ConfigurationAccess {

    @IBOutlet private weak var viewHeaderBackground: UIView!
    @IBOutlet private weak var viewHeader: UIView!
    @IBOutlet private weak var labelVersion: UILabel!
    @IBOutlet private weak var buttonCancel: UIButton!
    @IBOutlet private weak var constraintHeaderHeight: NSLayoutConstraint!
    @IBOutlet private weak var buttonEnvironment: UIButton!
    @IBOutlet private weak var imvLogo: UIImageView!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        imvLogo.image = Theme.current.palette.logo
        constraintHeaderHeight.constant = (Macros.isDeviceBig ? 250.0 : 150.0)
        buttonCancel.accessibilityLabel = L10n.Ui.Global.cancel
        buttonEnvironment.isHidden = !accessedConfiguration.isDevelopment
        labelVersion.text = Macros.localizedVersionFullString()
        
    }
    
    /**
     Creates a wrapped `GetStartedViewController` ready for presentation.
     */
    public static func with() -> UIViewController {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()
        return nav
    }


    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEnvironmentButton()
    }

    @IBAction private func toggleEnvironment(_ sender: Any?) {
        if (Client.environment == .production) {
            Client.environment = .staging
        } else {
            Client.environment = .production
        }
        refreshEnvironmentButton()
    }
    
    private func refreshEnvironmentButton() {
        if (Client.environment == .production) {
            buttonEnvironment.setTitle("Production", for: .normal)
        } else {
            buttonEnvironment.setTitle("Staging", for: .normal)
        }
    }
    
    // MARK: Restylable
    
    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyLightBackground(viewHeaderBackground)
        Theme.current.applyLightBackground(viewHeader)
        Theme.current.applyCancelButton(buttonCancel, appearance: .dark)
        Theme.current.applyCaption(labelVersion, appearance: .dark)
        
        buttonEnvironment.setTitleColor(buttonCancel.titleColor(for: .normal), for: .normal)
    }

}
