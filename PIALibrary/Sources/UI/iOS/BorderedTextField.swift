//
//  BorderedTextField.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/20/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

/// An `UITextField` specialization with a border that can highlight while editing.
public class BorderedTextField: UITextField {
    private static let allowedReadonlyActions: Set<Selector> = Set([
        #selector(select(_:)),
        #selector(selectAll(_:)),
        #selector(copy(_:))
    ])

    private static let allowedActions: Set<Selector> = Set([
        #selector(select(_:)),
        #selector(selectAll(_:)),
        #selector(copy(_:)),
        #selector(cut(_:)),
        #selector(paste(_:))
    ])
    
    private static let allowedSecureActions: Set<Selector> = Set([
        #selector(paste(_:))
    ])
    
    /// :nodoc:
    public override var placeholder: String? {
        didSet {
            reloadPlaceholder()
        }
    }
    
    /// The default color of the border.
    public var borderColor: UIColor? {
        didSet {
            if (!highlightsWhileEditing || !isEditing) {
                viewBorder?.backgroundColor = borderColor
            }
            reloadPlaceholder()
        }
    }
    
    /// The color of the border while highlighted.
    public var highlightedBorderColor: UIColor? = .blue {
        didSet {
            if (highlightsWhileEditing && isEditing) {
                viewBorder?.backgroundColor = highlightedBorderColor
            }
        }
    }
    
    /// When `true`, the text field border highlights while editing.
    public var highlightsWhileEditing = true
    
    /// When `true`, the text field can be edited.
    public var isEditable = true
    
    /// :nodoc:
    public override var delegate: UITextFieldDelegate? {
        get {
            return realDelegate
        }
        set {
            if (newValue as? BorderedTextField == self) {
                super.delegate = newValue
            } else {
                realDelegate = newValue
            }
        }
    }

    /// :nodoc:
    public override func awakeFromNib() {
        super.awakeFromNib()

        borderStyle = .none
        textColor = .darkText
        self.delegate = self
    }

    private weak var viewBorder: UIView?
    
    private weak var realDelegate: UITextFieldDelegate?
    
    /// :nodoc:
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        let border = UIView()
        border.backgroundColor = borderColor
        border.translatesAutoresizingMaskIntoConstraints = false
        addSubview(border)
        viewBorder = border

        reloadPlaceholder()

        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 0.5),
            border.leftAnchor.constraint(equalTo: leftAnchor),
            border.rightAnchor.constraint(equalTo: rightAnchor),
            border.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// :nodoc:
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let allowed: Set<Selector>
        if isSecureTextEntry {
            guard isEditable else {
                return false
            }
            allowed = BorderedTextField.allowedSecureActions
        } else {
            if isEditable {
                allowed = BorderedTextField.allowedActions
            } else {
                allowed = BorderedTextField.allowedReadonlyActions
            }
        }
        return allowed.contains(action)
    }
    
    private func reloadPlaceholder() {
        if let placeholder = placeholder, let placeholderColor = borderColor {
            let attributes: [NSAttributedStringKey: Any] = [
                .foregroundColor: placeholderColor
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
}

// XXX: hack to inject self delegate
/// :nodoc:
extension BorderedTextField: UITextFieldDelegate {
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let method = realDelegate?.textFieldShouldClear {
            return method(textField)
        }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let borderedTextField = textField as? BorderedTextField, borderedTextField.isEditable else {
            return false
        }
        if let method = realDelegate?.textField(_:shouldChangeCharactersIn:replacementString:) {
            return method(textField, range, string)
        }
        return true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let method = realDelegate?.textFieldShouldReturn(_:) {
            return method(textField)
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if highlightsWhileEditing {
            viewBorder?.backgroundColor = highlightedBorderColor
        }

        if let method = realDelegate?.textFieldDidBeginEditing(_:) {
            return method(textField)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        viewBorder?.backgroundColor = borderColor

        if let method = realDelegate?.textFieldDidEndEditing(_:) {
            return method(textField)
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let method = realDelegate?.textFieldShouldEndEditing {
            return method(textField)
        }
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let method = realDelegate?.textFieldShouldEndEditing(_:) {
            return method(textField)
        }
        return true
    }
}
