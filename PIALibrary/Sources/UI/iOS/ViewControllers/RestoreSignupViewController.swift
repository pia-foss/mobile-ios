//
//  RestoreSignupViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2020 Private Internet Access, Inc.
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

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

public class RestoreSignupViewController: AutolayoutViewController, BrandableNavigationBar, WelcomeChild {
    
    var omitsSiblingLink = false

    var completionDelegate: WelcomeCompletionDelegate?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var viewModal: UIView!
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelDescription: UILabel!
    
    @IBOutlet private weak var textEmail: BorderedTextField!
    
    @IBOutlet private weak var buttonRestorePurchase: PIAButton!

    var preset: Preset?

    private var signupEmail: String?
    private var isRunningActivity = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(back(_:))
        )
        self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back

        labelTitle.text = L10n.Welcome.Restore.title
        labelDescription.text = L10n.Welcome.Restore.subtitle
        textEmail.placeholder = L10n.Welcome.Restore.Email.placeholder

        textEmail.text = preset?.purchaseEmail

        // XXX: signup scrolling hack, disable on iPad and iPhone Plus
        if Macros.isDeviceBig {
            scrollView.isScrollEnabled = false
        }
        
        styleRestoreButton()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableInteractions(true)
    }
    
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // signup after receipt restore
        if (segue.identifier == StoryboardSegue.Welcome.signupViaRestoreSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController
            
            guard let email = signupEmail else {
                fatalError("Signing up and signupEmail is not set")
            }
            var metadata = SignupMetadata(email: email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.metadata = metadata
            vc.preset = preset
            vc.signupRequest = SignupRequest(email: email)
            vc.completionDelegate = completionDelegate
        }
    }
    
    // MARK: Actions

    @IBAction private func restorePurchase(_ sender: Any?) {
        guard !isRunningActivity else {
            return
        }
    
        guard let email = textEmail.text, Validator.validate(email: email.trimmed()) else {
            signupEmail = nil
            textEmail.becomeFirstResponder()
            Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                    message: L10n.Welcome.Purchase.Error.validation)
            self.status = .error(element: textEmail)
            return
        }
        
        self.status = .restore(element: textEmail)
        signupEmail = email.trimmed()
    
        enableInteractions(false)
        isRunningActivity = true
        self.showLoadingAnimation()
        preset?.accountProvider.restorePurchases { (error) in
            self.hideLoadingAnimation()
            self.isRunningActivity = false
            if let _ = error {
                self.reportRestoreFailure(error)
                self.enableInteractions(true)
                return
            }
            self.reportRestoreSuccess()
        }
    }
    
    private func reportRestoreSuccess() {
        log.debug("Restored payment receipt, redeeming...");
        
        guard let email = signupEmail else {
            fatalError("Restore receipt and signupEmail is not set")
        }
        self.restoreController(self,
                               didRefreshReceiptWith: email)
    }
    
    private func reportRestoreFailure(_ optionalError: Error?) {
        var message = optionalError?.localizedDescription ?? L10n.Welcome.Iap.Error.title
        if let error = optionalError {
            log.error("Failed to restore payment receipt (error: \(error))")
        } else {
            log.error("Failed to restore payment receipt")
        }
        Macros.displayImageNote(withImage: Asset.iconWarning.image,
                                message: message)

    }

    private func enableInteractions(_ enable: Bool) {
        textEmail.isEnabled = enable
    }
    
    // MARK: Restylable

    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewModal)
        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelDescription)
        Theme.current.applyInput(textEmail)
    }
    
    private func styleRestoreButton() {
        buttonRestorePurchase.setRounded()
        buttonRestorePurchase.style(style: TextStyle.Buttons.piaGreenButton)
        buttonRestorePurchase.setTitle(L10n.Welcome.Restore.submit.uppercased(),
                              for: [])
    }

    private func restoreController(_ restoreController: RestoreSignupViewController, didRefreshReceiptWith email: String) {
        self.signupEmail = email
        self.perform(segue: StoryboardSegue.Welcome.signupViaRestoreSegue)
    }
    
}

extension RestoreSignupViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textEmail) {
            restorePurchase(nil)
        }
        return true
    }
}

