//
//  SignupInProgressViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
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

public class SignupInProgressViewController: AutolayoutViewController, BrandableNavigationBar {
    @IBOutlet private weak var progressView: CircleProgressView!

    @IBOutlet private weak var titleMessage: UILabel!
    @IBOutlet private weak var labelMessage: UILabel!

    var signupRequest: SignupRequest?

    var redeemRequest: RedeemRequest?
    
    var preset: Preset?

    var metadata: SignupMetadata?
    
    weak var completionDelegate: WelcomeCompletionDelegate?
    
    private var user: UserAccount?
    
    private var error: Error?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        labelMessage.text = metadata?.bodySubtitle
        titleMessage.text = metadata?.title
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        progressView.startAnimating()

        if let request = signupRequest {
            performSignup(with: request)
        }
    }
    
    private func performSignup(with request: SignupRequest) {
        log.debug("Signing up...")

        preset?.accountProvider.signup(with: request) { (user, error) in
            guard let user = user else {
                self.user = nil
                self.error = error
                if let clientError = error as? ClientError, (clientError == .internetUnreachable) {
                    log.error("Failed to sign up: Internet is unreachable")
                    self.perform(segue: StoryboardSegue.Signup.internetUnreachableSegueIdentifier, sender: nil)
                    return
                }
                if let error = error {
                    log.error("Failed to sign up (error: \(error))")
                } else {
                    log.error("Failed to sign up")
                }
                self.perform(segue: StoryboardSegue.Signup.failureSegueIdentifier)
                return
            }

            log.debug("Sign-up succeeded!")

            self.user = user
            self.error = nil
            self.perform(segue: StoryboardSegue.Signup.successSegueIdentifier)
        }
    }
        
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueType = StoryboardSegue.Signup(rawValue: identifier) else {
            return
        }
        switch segueType {
        case .successSegueIdentifier:
                        
            guard let email = signupRequest?.email ?? redeemRequest?.email else {
                fatalError("Email not provided with signup or redeem request")
            }
            
            let vc = segue.destination as! ConfirmVPNPlanViewController
            var metadata = SignupMetadata(email: email, user: user)
            if let _ = signupRequest {
                metadata.title = L10n.Signup.InProgress.title
                metadata.bodyImage = Asset.imagePurchaseSuccess.image
                metadata.bodyTitle = L10n.Signup.Success.title
                metadata.bodySubtitle = L10n.Signup.Success.messageFormat(metadata.email)
            } else if let _ = redeemRequest {
                metadata.title = L10n.Welcome.Redeem.title
                metadata.bodyImage = Asset.imageRedeemSuccess.image
                metadata.bodyImageOffset = CGPoint(x: -10.0, y: 0.0)
                metadata.bodyTitle = L10n.Signup.Success.Redeem.title
                metadata.bodySubtitle = L10n.Signup.Success.Redeem.message
            }
            vc.preset = preset
            vc.metadata = metadata
            vc.completionDelegate = completionDelegate
            
        case .failureSegueIdentifier:
            let vc = segue.destination as! SignupFailureViewController
            vc.error = error
            break

        default:
            break
        }
    }
    
    // MARK: Unwind
    
    @IBAction private func unwoundSignupInternetUnreachable(segue: UIStoryboardSegue) {
    }

    // MARK: Restylable
    
    override public func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyPrincipalBackground(viewContainer!)
        Theme.current.applyTitle(titleMessage, appearance: .dark)
        Theme.current.applySubtitle(labelMessage)
        Theme.current.applyCircleProgressView(progressView)
    }
}
