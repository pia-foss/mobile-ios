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
}
