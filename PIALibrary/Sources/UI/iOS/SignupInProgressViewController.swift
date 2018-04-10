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

    var request: SignupRequest!

    var preset: PIAWelcomeViewController.Preset?

    weak var completionDelegate: WelcomeCompletionDelegate?
    
    private var user: UserAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelMessage.text = L10n.Signup.InProgress.message
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        progressView.startAnimating()
        performSignup()
    }
    
    private func performSignup() {
        log.debug("Signing up...")

        preset?.accountProvider.signup(with: request) { (user, error) in
            guard let user = user else {
                self.user = nil
                if let clientError = error as? ClientError, (clientError == .internetUnreachable) {
                    log.error("Failed to sign up: Internet is unreachable")
                    self.perform(segue: StoryboardSegue.Signup.internetUnreachableSegueIdentifier, sender: nil)
                } else {
                    if let error = error {
                        log.error("Failed to sign up (error: \(error))")
                    } else {
                        log.error("Failed to sign up")
                    }
                    self.perform(segue: StoryboardSegue.Signup.failureSegueIdentifier)
                }
                return
            }

            log.debug("Sign-up succeeded!")

            self.user = user
            self.perform(segue: StoryboardSegue.Signup.successSegueIdentifier)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueType = StoryboardSegue.Signup(rawValue: identifier) else {
            return
        }
        switch segueType {
        case .successSegueIdentifier:
            let vc = segue.destination as! SignupSuccessViewController
            vc.email = request.email
            vc.user = user
            vc.completionDelegate = completionDelegate
            
        case .failureSegueIdentifier:
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
