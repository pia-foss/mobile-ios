//
//  ActivityButton.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/// A button with an embedded `UIActivityIndicatorView` for simulating a running activity.
public class ActivityButton: UIControl {

    /// :nodoc:
    public override var backgroundColor: UIColor? {
        get {
            return button.backgroundColor
        }
        set {
            button.backgroundColor = newValue
        }
    }
    
    /// :nodoc:
    public override var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
        }
    }

    /// :nodoc:
    public override var accessibilityIdentifier: String? {
        get {
            return button.accessibilityIdentifier
        }
        set {
            button.accessibilityIdentifier = newValue
        }
    }
    
    /// The button text color.
    public var textColor: UIColor? {
        get {
            return button.titleColor(for: .normal)
        }
        set {
            button.setTitleColor(newValue, for: .normal)
        }
    }

    /// The button title.
    public var title: String? {
        get {
            return button.title(for: .normal)
        }
        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    /// The button font.
    public var font: UIFont? {
        get {
            return button.titleLabel?.font
        }
        set {
            button.titleLabel?.font = newValue
        }
    }

    /// The button corner radius.
    public var cornerRadius: CGFloat {
        get {
            return button.layer.cornerRadius
        }
        set {
            button.layer.cornerRadius = newValue
        }
    }

    /// This is `true` after invoking `startActivity()`.
    public var isRunningActivity: Bool {
        return activity.isAnimating
    }

    private lazy var button = UIButton(type: .custom)

    private lazy var activity = UIActivityIndicatorView(frame: .zero)
    
    private var previousTitle: String?
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .clear
        
        button.showsTouchWhenHighlighted = true // XXX: should replicate IB highlight behaviour
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonTouch), for: .touchUpInside)
        addSubview(button)
        
        activity.hidesWhenStopped = true
        activity.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activity)
        
        let top = button.topAnchor.constraint(equalTo: topAnchor)
        let bottom = button.bottomAnchor.constraint(equalTo: bottomAnchor)
        let left = button.leftAnchor.constraint(equalTo: leftAnchor)
        let right = button.rightAnchor.constraint(equalTo: rightAnchor)
        let activityX = activity.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        let activityY = activity.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        NSLayoutConstraint.activate([top, bottom, left, right, activityX, activityY])
    }

    /**
     Simulates an activity by showing a spinning activity indicator.
     */
    public func startActivity() {
        guard !activity.isAnimating else {
            return
        }
        previousTitle = title
        button.isUserInteractionEnabled = false
        title = nil
        activity.startAnimating()
    }

    /**
     Hides the activity indicator previously shown with `startActivity()`.
     */
    public func stopActivity() {
        guard activity.isAnimating else {
            return
        }
        activity.stopAnimating()
        title = previousTitle
        button.isUserInteractionEnabled = true
    }

    @objc private func handleButtonTouch() {
        sendActions(for: .touchUpInside)
    }
}
