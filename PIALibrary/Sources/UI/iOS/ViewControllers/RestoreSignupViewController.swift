//
//  RestoreSignupViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/21/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class RestoreSignupViewController: AutolayoutViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var viewModal: UIView!
    
    @IBOutlet private weak var labelTitle: UILabel!
    
    @IBOutlet private weak var labelDescription: UILabel!
    
    @IBOutlet private weak var textEmail: BorderedTextField!
    
    @IBOutlet private weak var buttonRestorePurchase: ActivityButton!

    @IBOutlet private weak var buttonDismiss: UIButton!

    var preset: Preset?

    weak var delegate: RestoreSignupViewControllerDelegate?

    private var signupEmail: String?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        labelTitle.text = L10n.Welcome.Restore.title
        labelDescription.text = L10n.Welcome.Restore.subtitle
        textEmail.placeholder = L10n.Welcome.Restore.Email.placeholder
        buttonRestorePurchase.title = L10n.Welcome.Restore.submit
        buttonDismiss.accessibilityLabel = L10n.Ui.Global.cancel

        textEmail.text = preset?.purchaseEmail

        // XXX: signup scrolling hack, disable on iPad and iPhone Plus
        if Macros.isDeviceBig {
            scrollView.isScrollEnabled = false
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        nc.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: .UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        enableInteractions(true)
    }
    
    // MARK: Actions
    
    @IBAction private func restorePurchase(_ sender: Any?) {
        guard !buttonRestorePurchase.isRunningActivity else {
            return
        }
    
        guard let email = textEmail.text, Validator.validate(email: email) else {
            signupEmail = nil
            textEmail.becomeFirstResponder()
            return
        }
        signupEmail = email
    
        enableInteractions(false)
        preset?.accountProvider.restorePurchases { (error) in
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
        delegate?.restoreController(self, didRefreshReceiptWith: email)
    }
    
    private func reportRestoreFailure(_ optionalError: Error?) {
        if let error = optionalError {
            log.error("Failed to restore payment receipt (error: \(error))")
        } else {
            log.error("Failed to restore payment receipt")
        }
        
        let alert = Macros.alert(
            L10n.Welcome.Iap.Error.title,
            optionalError?.localizedDescription ?? ""
        )
        alert.addCancelAction(L10n.Ui.Global.close)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func dismiss(_ sender: Any?) {
        view.endEditing(false)
        delegate?.restoreControllerDidDismiss(self)
    }

    private func enableInteractions(_ enable: Bool) {
        textEmail.isEnabled = enable
        if enable {
            buttonRestorePurchase.stopActivity()
        } else {
            buttonRestorePurchase.startActivity()
        }
    }
    
    // MARK: Notifications
    
    @objc private func keyboardDidShow(notification: Notification) {
        buttonDismiss.isUserInteractionEnabled = false
    }
    
    @objc private func keyboardDidHide(notification: Notification) {
        buttonDismiss.isUserInteractionEnabled = true
    }
    
    // MARK: Restylable

    override func viewShouldRestyle() {
        super.viewShouldRestyle()

        Theme.current.applyOverlay(view)
        Theme.current.applySolidLightBackground(viewModal)
        Theme.current.applyCorner(viewModal)

        Theme.current.applyTitle(labelTitle, appearance: .dark)
        Theme.current.applySubtitle(labelDescription)
        Theme.current.applyInput(textEmail)
        Theme.current.applyActionButton(buttonRestorePurchase)
    }
}

extension RestoreSignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == textEmail) {
            restorePurchase(nil)
        }
        return true
    }
}

protocol RestoreSignupViewControllerDelegate: class {
    func restoreController(_ restoreController: RestoreSignupViewController, didRefreshReceiptWith email: String)

    func restoreControllerDidDismiss(_ restoreController: RestoreSignupViewController)
}
