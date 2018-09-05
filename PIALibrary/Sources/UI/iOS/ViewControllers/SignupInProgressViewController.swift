//
//  SignupInProgressViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/8/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import SwiftyBeaver

private let log = SwiftyBeaver.self

class SignupInProgressViewController: AutolayoutViewController {
    @IBOutlet private weak var progressView: CircleProgressView!

    @IBOutlet private weak var labelMessage: UILabel!

    var signupRequest: SignupRequest?

    var redeemRequest: RedeemRequest?
    
    var preset: PIAWelcomeViewController.Preset?

    var metadata: SignupMetadata?
    
    weak var completionDelegate: WelcomeCompletionDelegate?
    
    private var user: UserAccount?
    
    private var error: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = metadata?.title
        labelMessage.text = metadata?.bodySubtitle
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        progressView.startAnimating()

        if let request = signupRequest {
            performSignup(with: request)
        } else if let request = redeemRequest {
            performRedeem(with: request)
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
    
    private func performRedeem(with request: RedeemRequest) {
        log.debug("Redeeming...")
        
        preset?.accountProvider.redeem(with: request) { (user, error) in
            guard let user = user else {
                self.user = nil
                self.error = error
                if let clientError = error as? ClientError, (clientError == .internetUnreachable) {
                    log.error("Failed to redeem: Internet is unreachable")
                    self.perform(segue: StoryboardSegue.Signup.internetUnreachableSegueIdentifier, sender: nil)
                    return
                }
                if let error = error {
                    log.error("Failed to redeem (error: \(error))")
                } else {
                    log.error("Failed to redeem")
                }
                self.perform(segue: StoryboardSegue.Signup.failureSegueIdentifier)
                return
            }
            
            log.debug("Redeem succeeded!")
            
            self.user = user
            self.error = nil
            self.perform(segue: StoryboardSegue.Signup.successSegueIdentifier)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueType = StoryboardSegue.Signup(rawValue: identifier) else {
            return
        }
        switch segueType {
        case .successSegueIdentifier:
            guard let email = signupRequest?.email ?? redeemRequest?.email else {
                fatalError("Email not provided with signup or redeem request")
            }
            
            let vc = segue.destination as! SignupSuccessViewController
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
    
    override func viewShouldRestyle() {
        super.viewShouldRestyle()
        
        Theme.current.applyBody1(labelMessage, appearance: .dark)
        Theme.current.applyCircleProgressView(progressView)
    }
}
