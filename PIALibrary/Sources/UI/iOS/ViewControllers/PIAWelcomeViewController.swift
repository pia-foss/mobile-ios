//
//  PIAWelcomeViewController.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/**
 The welcome view controller is a graphic gateway to the PIA services.
 */
public class PIAWelcomeViewController: AutolayoutViewController, WelcomeCompletionDelegate, ConfigurationAccess, InAppAccess, BrandableNavigationBar {
 
    @IBOutlet private weak var buttonCancel: UIButton!    
    @IBOutlet private weak var buttonEnvironment: UIButton!

    var preset = Preset()

    private var pendingSignupRequest: SignupRequest?
    weak var delegate: PIAWelcomeViewControllerDelegate?
    
    /// It's `true` if the controller was created with `Preset.isEphemeral`.
    ///
    /// - Seealso: `Preset.isEphemeral`
    public var isEphemeral: Bool {
        return preset.isEphemeral
    }
    
    /**
     Creates a wrapped `PIAWelcomeViewController` ready for presentation.
     
     - Parameter preset: The optional `Preset` to configure this controller with
     - Parameter delegate: The `PIAWelcomeViewControllerDelegate` to handle raised events
     */
    public static func with(preset: Preset? = nil, delegate: PIAWelcomeViewControllerDelegate? = nil) -> UIViewController {
        let nav = StoryboardScene.Welcome.initialScene.instantiate()
        let vc = nav.topViewController as! PIAWelcomeViewController
        if let customPreset = preset {
            vc.preset = customPreset
        }
        vc.delegate = delegate
        return nav
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// :nodoc:
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard !preset.accountProvider.isLoggedIn else {
            fatalError("You are already logged in, you might want to Client.database.truncate() to start clean")
        }
        
        buttonCancel.isHidden = true
        buttonEnvironment.isHidden = !accessedConfiguration.isDevelopment
        
        #if os(iOS)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(inAppDidAddUncredited(notification:)), name: .__InAppDidAddUncredited, object: nil)
        #endif

    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !preset.openFromDashboard {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: Theme.current.palette.navigationBarBackIcon?.withRenderingMode(.alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(back(_:))
            )
            self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Welcome.Redeem.Accessibility.back
        } else {
            if preset.allowsCancel {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: Asset.iconClose.image.withRenderingMode(.alwaysOriginal),
                    style: .plain,
                    target: self,
                    action: #selector(cancelClicked(_:))
                )
                self.navigationItem.leftBarButtonItem?.accessibilityLabel = L10n.Ui.Global.cancel
            }
        }

        refreshEnvironmentButton()
    }
    
    /// :nodoc:
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tryRecoverSignupProcess()
    }
    
    // MARK: Actions
    @objc private func back(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func cancelClicked(_ sender: Any?) {
        delegate?.welcomeControllerDidCancel(self)
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

    private func tryRecoverSignupProcess() {
        guard preset.shouldRecoverPendingSignup else {
            return
        }
        guard let request = preset.accountProvider.lastSignupRequest else {
            return
        }
        guard (pendingSignupRequest == nil) else {
            return
        }
        guard accessedStore.hasUncreditedTransactions else {
            return
        }
        pendingSignupRequest = request
        perform(segue: StoryboardSegue.Welcome.signupViaRecoverSegue)
    }
    
    /// :nodoc:
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WelcomePageViewController {
            vc.preset = preset
            vc.completionDelegate = self
        }
        // recover pending signup
        else if (segue.identifier == StoryboardSegue.Welcome.signupViaRecoverSegue.rawValue) {
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! SignupInProgressViewController
            
            guard let request = pendingSignupRequest else {
                fatalError("Recovering signup and pendingSignupRequest is not set")
            }
            var metadata = SignupMetadata(email: request.email)
            metadata.title = L10n.Signup.InProgress.title
            metadata.bodySubtitle = L10n.Signup.InProgress.message
            vc.metadata = metadata
            vc.signupRequest = request
        }
    }
    
    // MARK: WelcomeCompletionDelegate
    
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController) {
        delegate?.welcomeController(self, didLoginWith: user, topViewController: topViewController)
    }
    
    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController) {
        delegate?.welcomeController(self, didSignupWith: user, topViewController: topViewController)
    }

    // MARK: Notifications
    
    #if os(iOS)
    @objc private func inAppDidAddUncredited(notification: Notification) {
        tryRecoverSignupProcess()
    }
    #endif
    
    // MARK: Size classes
    
    // consider compact height in landscape
    /// :nodoc:
    public override var traitCollection: UITraitCollection {
        if isLandscape {
            return UITraitCollection(verticalSizeClass: .compact)
        }
        return super.traitCollection
    }
    
    // MARK: Restylable
    
    /// :nodoc:
    public override func viewShouldRestyle() {
        super.viewShouldRestyle()
        navigationItem.titleView = NavigationLogoView()
        Theme.current.applyPrincipalBackground(view)
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applyCancelButton(buttonCancel, appearance: .dark)
        buttonEnvironment.setTitleColor(buttonCancel.titleColor(for: .normal), for: .normal)
    }
}

/// Receives events from a `PIAWelcomeViewController`.
public protocol PIAWelcomeViewControllerDelegate: class {

    /**
     Invoked after a successful login.
     
     - Parameter welcomeController: The delegating controller
     - Parameter user: The logged in `UserAccount`
     */
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didLoginWith user: UserAccount, topViewController: UIViewController)

    /**
     Invoked after a successful signup.
     
     - Parameter welcomeController: The delegating controller
     - Parameter user: The signed up `UserAccount`
     */
    func welcomeController(_ welcomeController: PIAWelcomeViewController, didSignupWith user: UserAccount, topViewController: UIViewController)

    /**
     Invoked after a cancel.
     
     - Parameter welcomeController: The delegating controller
     */
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController)
}

public extension PIAWelcomeViewControllerDelegate {
    func welcomeControllerDidCancel(_ welcomeController: PIAWelcomeViewController) {
    }
}

protocol WelcomeChild: class {
    var preset: Preset? { get set }
    
    var omitsSiblingLink: Bool { get set }
    
    var completionDelegate: WelcomeCompletionDelegate? { get set }
}

protocol WelcomeCompletionDelegate: class {
    func welcomeDidLogin(withUser user: UserAccount, topViewController: UIViewController)
    
    func welcomeDidSignup(withUser user: UserAccount, topViewController: UIViewController)
}

class EphemeralAccountProvider: AccountProvider, ProvidersAccess, InAppAccess {
    
    // XXX: we want legit web services calls, yet allow the option to mock them
    private var webServices: WebServices? {
        guard let accountProvider = accessedProviders.accountProvider as? WebServicesConsumer else {
            fatalError("Current accountProvider is not a WebServicesConsumer. Use MockAccountProvider for mocking ephemeral Welcome process")
        }
        return accountProvider.webServices
    }
    
    var planProducts: [Plan : InAppProduct]? {
        return accessedProviders.accountProvider.planProducts
    }
    
    var isLoggedIn = false
    
    var token: String?

    var currentUser: UserAccount?
    
    var publicUsername: String?

    var currentPasswordReference: Data? {
        return nil
    }
    
    var lastSignupRequest: SignupRequest? {
        return nil
    }
    
    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        
        webServices?.token(credentials: request.credentials) { (token, error) in
            guard let token = token else {
                callback?(nil, error)
                return
            }
            
            self.webServices?.info(token: token) { (info, error) in
                guard let info = info else {
                    callback?(nil, error)
                    return
                }
                let user = UserAccount(credentials: request.credentials, info: info)
                self.currentUser = user
                self.isLoggedIn = true
                callback?(user, nil)
            }

        }
    }
    
    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func update(with request: UpdateAccountRequest, andPassword password: String, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func logout(_ callback: SuccessLibraryCallback?) {
        fatalError("Not implemented")
    }

    func cleanDatabase() {
        fatalError("Not implemented")
    }
    
    func listPlanProducts(_ callback: (([Plan : InAppProduct]?, Error?) -> Void)?) {
        accessedProviders.accountProvider.listPlanProducts(callback)
    }
    
    func purchase(plan: Plan, _ callback: ((InAppTransaction?, Error?) -> Void)?) {
        accessedProviders.accountProvider.purchase(plan: plan, callback)
    }
    
    func restorePurchases(_ callback: SuccessLibraryCallback?) {
        accessedProviders.accountProvider.restorePurchases(callback)
    }
    
    func signup(with request: SignupRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        guard let signup = request.signup(withStore: accessedStore) else {
            callback?(nil, ClientError.noReceipt)
            return
        }

        webServices?.signup(with: signup) { (credentials, error) in
            guard let credentials = credentials else {
                callback?(nil, error)
                return
            }
            let user = UserAccount(credentials: credentials, info: nil)
            self.currentUser = user
            self.isLoggedIn = true
            callback?(user, nil)
        }
    }
    
    func redeem(with request: RedeemRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        let redeem = Redeem(email: request.email, code: request.code)
        
        webServices?.redeem(with: redeem) { (credentials, error) in
            guard let credentials = credentials else {
                callback?(nil, error)
                return
            }
            let user = UserAccount(credentials: credentials, info: nil)
            self.currentUser = user
            self.isLoggedIn = true
            callback?(user, nil)
        }
    }
    
    func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func isAPIEndpointAvailable(_ callback: LibraryCallback<Bool>?) {
        guard let webServices = webServices else {
            callback?(false, nil)
            return
        }
        let task = webServices.taskForConnectivityCheck { (_, error) in
            callback?(error == nil, error)
        }
        task.resume()
    }

}
