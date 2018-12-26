//
//  AutolayoutViewControllers.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit
import Lottie
/// Declares a generic, dismissable modal controller.
public protocol ModalController: class {

    /**
     Dismisses the modal controller.
     */
    func dismissModal()
}

public protocol AnimatingLoadingDelegate: class {
    func showLoadingAnimation()
    func hideLoadingAnimation()
    func adjustLottieSize()
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
    
    public func styleNavigationBarWithTitle(_ title: String) {
        
        let currentStatus = Client.providers.vpnProvider.vpnStatus
        
        switch currentStatus {
        case .connected:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: TextStyle.textStyle6)
            titleLabelView.text = title
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: .white,
                                                   andBarTintColors: [UIColor.piaGreen,
                                                                      UIColor.piaGreenDark20])
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        default:
            let titleLabelView = UILabel(frame: CGRect.zero)
            titleLabelView.style(style: Theme.current.palette.appearance == .dark ?
                TextStyle.textStyle6 :
                TextStyle.textStyle7)
            titleLabelView.text = title
            Theme.current.applyCustomNavigationBar(navigationController!.navigationBar,
                                                   withTintColor: nil,
                                                   andBarTintColors: nil)
            navigationItem.titleView = titleLabelView
            setNeedsStatusBarAppearanceUpdate()
            
        }
    }


}

extension AutolayoutViewController: AnimatingLoadingDelegate {
    
    private struct LottieRepos {
        static var graphLoad: LOTAnimationView?
        static var containerView: UIView?
    }
    
    var graphLoad: LOTAnimationView? {
        get {
            return objc_getAssociatedObject(self, &LottieRepos.graphLoad) as? LOTAnimationView
        }
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &LottieRepos.graphLoad, unwrappedValue as LOTAnimationView?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    var containerView: UIView? {
        get {
            return LottieRepos.containerView
        }
        set {
            if let unwrappedValue = newValue {
                LottieRepos.containerView = unwrappedValue
            }
        }
    }

    public func showLoadingAnimation() {
        if graphLoad == nil {
            containerView = UIView(frame: UIScreen.main.bounds)
            containerView?.backgroundColor = Theme.current.palette.appearance == .dark ?
                UIColor.black.withAlphaComponent(0.72) :
                UIColor.piaGrey1.withAlphaComponent(0.75)
            graphLoad = LOTAnimationView(name: "pia-spinner")
            adjustLottieSize()
        }
        addLoadingAnimation()
    }
    
    private func addLoadingAnimation() {
        graphLoad?.loopAnimation = true
        if let graphLoad = graphLoad,
            let containerView = containerView {
            if let key = self.navigationController?.view {
                key.addSubview(containerView)
                key.addSubview(graphLoad)
            }
            graphLoad.play()
        }
    }
    
    public func hideLoadingAnimation() {
        graphLoad?.stop()
        graphLoad?.removeFromSuperview()
        containerView?.removeFromSuperview()
    }
    
    public func adjustLottieSize() {
        let lottieWidth = UIScreen.main.bounds.width/4
        graphLoad?.frame = CGRect(
            x: (UIScreen.main.bounds.width/2) - (lottieWidth/2),
            y: (UIScreen.main.bounds.height - lottieWidth)/2,
            width: lottieWidth,
            height: lottieWidth
        )
    }

}
