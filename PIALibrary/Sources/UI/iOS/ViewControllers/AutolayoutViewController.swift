//
//  AutolayoutViewControllers.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/// Declares a generic, dismissable modal controller.
public protocol ModalController: class {

    /**
     Dismisses the modal controller.
     */
    func dismissModal()
}

/// Enum used to determinate the status of the view controller and apply effects over the UI elements
public enum ViewControllerStatus {
    case initial
    case restore(element: UIView)
    case error(element: UIView)
}

/// Base view controller with dynamic constraints and restyling support.
///
/// - Seealso: `Theme`
open class AutolayoutViewController: UIViewController, ModalController, Restylable {

    /// The outlet to the main view container (optional).
    ///
    /// - Seealso: `ThemeStrategy.autolayoutContainerMargins(for:)`
    @IBOutlet public weak var viewContainer: UIView?

    /// :nodoc:
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return Theme.current.statusBarAppearance(for: self)
    }
    
    /// The initial status of the view controller. Every time the var changes the value, we reload the UI of the form element given as parameter.
    /// Example of use: self.status = .error(element: textEmail)
    open var status: ViewControllerStatus = .initial {
        didSet { reloadFormElements() }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// :nodoc:
    open override func viewDidLoad() {
        super.viewDidLoad()

        if let viewContainer = viewContainer {
            Theme.current.applySolidLightBackground(viewContainer)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewShouldRestyle), name: .PIAThemeDidChange, object: nil)
        viewShouldRestyle()
    }
    
    /// :nodoc:
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        refreshOrientationConstraints(size: view.bounds.size)
    }
    
    private func refreshOrientationConstraints(size: CGSize) {
        if let viewContainer = viewContainer {
            let orientation: UIInterfaceOrientationMask = (isLandscape ? .landscape : .portrait)
            viewContainer.layoutMargins = Theme.current.autolayoutContainerMargins(for: orientation)
        }
        didRefreshOrientationConstraints()
    }

    // MARK: Public interface

    /// Shortcut for signalling landscape orientation.
    public var isLandscape: Bool {
        return (view.bounds.size.width > view.bounds.size.height)
    }

    /**
     Called right after refreshing the orientation contraints, e.g. when the device rotates.
     */
    open func didRefreshOrientationConstraints() {
    }
    
    // MARK: ModalController
    
    /// :nodoc:
    @objc open func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Restylable
    
    /// :nodoc:
    @objc open func viewShouldRestyle() {
        Theme.current.applyNavigationBarStyle(to: self)
        Theme.current.applySolidLightBackground(view)
        if let viewContainer = viewContainer {
            Theme.current.applySolidLightBackground(viewContainer)
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func reloadFormElements() {
        switch status {
        case .initial:
            break
        case .restore(let element):
            restoreFormElementBorder(element)
        case .error(let element):
            updateFormElementBorder(element)
        }
    }
    
    private func restoreFormElementBorder(_ element: UIView) {
        if let element = element as? UITextField {
            Theme.current.applyInput(element)
            element.rightView = nil
        }
    }
    
    private func updateFormElementBorder(_ element: UIView) {
        if let element = element as? UITextField {
            Theme.current.applyInputError(element)
            let iconWarning = UIImageView(image:Asset.iconWarning.image.withRenderingMode(.alwaysTemplate))
            iconWarning.tintColor = .piaRed
            element.rightView = iconWarning
        }
    }

}
