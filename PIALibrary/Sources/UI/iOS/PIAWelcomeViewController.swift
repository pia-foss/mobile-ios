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
public class PIAWelcomeViewController: AutolayoutViewController, WelcomeCompletionDelegate, ConfigurationAccess, InAppAccess {
 
    /// The sub-pages offered in the `PIAWelcomeViewController` user interface.
    public struct Pages: OptionSet {
        
        /// The login page.
        public static let login = Pages(rawValue: 0x01)
        
        /// The purchase plan page.
        public static let purchase = Pages(rawValue: 0x02)
        
        /// The redeem page.
        public static let redeem = Pages(rawValue: 0x04)
        
        /// All pages.
        public static let all: Pages = [.login, .purchase, .redeem]
        
        /// :nodoc:
        public let rawValue: Int
        
        /// :nodoc:
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    /// Optional preset values for welcome forms.
    public struct Preset: ProvidersAccess {

        /// The `Pages` to display in the scroller.
        public var pages = Pages.all
        
        /// If `true`, the controller can be cancelled.
        public var allowsCancel = false
        
        /// The login username.
        public var loginUsername: String?
        
        /// The login password.
        public var loginPassword: String?
        
        /// The purchase email address.
        public var purchaseEmail: String?
        
        /// The redeem email address.
        public var redeemEmail: String?
        
        /// The redeem code.
        public var redeemCode: String?
        
        /// If `true`, tries to recover any pending signup process.
        public var shouldRecoverPendingSignup = true
        
        /// If `true`, doesn't persist state to current `Client.database`.
        public var isEphemeral = false
        
        var accountProvider: AccountProvider {
            return (isEphemeral ? EphemeralAccountProvider() : accessedProviders.accountProvider)
        }
        
        /// Default initializer.
        public init() {
        }
    }

    @IBOutlet private weak var viewHeaderBackground: UIView!

    @IBOutlet private weak var viewHeader: UIView!

    @IBOutlet private weak var labelVersion: UILabel!
    
    @IBOutlet private weak var buttonCancel: UIButton!
    
    @IBOutlet private weak var constraintHeaderHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var buttonEnvironment: UIButton!

    @IBOutlet private weak var imvLogo: UIImageView!

    private var preset = Preset()

    private var pendingSignupRequest: SignupRequest?
    
    private weak var delegate: PIAWelcomeViewControllerDelegate?
    
    /// It's `true` if the controller was created with `PIAWelcomeViewController.Preset.isEphemeral`.
    ///
    /// - Seealso: `PIAWelcomeViewController.Preset.isEphemeral`
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
        
        imvLogo.image = Theme.current.palette.logo
        constraintHeaderHeight.constant = (Macros.isDeviceBig ? 250.0 : 150.0)
        buttonCancel.isHidden = !preset.allowsCancel
        buttonCancel.accessibilityLabel = L10n.Ui.Global.cancel
        buttonEnvironment.isHidden = !accessedConfiguration.isDevelopment
        labelVersion.text = Macros.localizedVersionFullString()
        
        #if os(iOS)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(inAppDidAddUncredited(notification:)), name: .__InAppDidAddUncredited, object: nil)
        #endif
    }
    
    /// :nodoc:
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshEnvironmentButton()
    }
    
    /// :nodoc:
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tryRecoverSignupProcess()
    }
    
    // MARK: Actions
    
    @IBAction private func cancelClicked(_ sender: Any?) {
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
            vc.request = request
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
        
        Theme.current.applyLightBackground(viewHeaderBackground)
        Theme.current.applyLightBackground(viewHeader)
        Theme.current.applyCancelButton(buttonCancel, appearance: .dark)
        Theme.current.applyCaption(labelVersion, appearance: .dark)

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
    var preset: PIAWelcomeViewController.Preset? { get set }
    
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
    
    var currentUser: UserAccount?
    
    var currentPasswordReference: Data? {
        return nil
    }
    
    var lastSignupRequest: SignupRequest? {
        return nil
    }
    
    func login(with request: LoginRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        webServices?.info(credentials: request.credentials) { (info, error) in
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
    
    func refreshAccountInfo(_ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func update(with request: UpdateAccountRequest, _ callback: ((AccountInfo?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func logout(_ callback: SuccessLibraryCallback?) {
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
    
    func listRenewablePlans(_ callback: (([Plan]?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
    
    func renew(with request: RenewRequest, _ callback: ((UserAccount?, Error?) -> Void)?) {
        fatalError("Not implemented")
    }
}
