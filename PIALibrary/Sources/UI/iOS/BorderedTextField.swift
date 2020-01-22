//
//  BorderedTextField.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/20/17.
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
                self.layer.borderColor = borderColor?.cgColor
            }
            reloadPlaceholder()
        }
    }
    
    /// The color of the border while highlighted.
    public var highlightedBorderColor: UIColor? = .blue {
        didSet {
            if (highlightsWhileEditing && isEditing) {
                self.layer.borderColor = highlightedBorderColor?.cgColor
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
        rightViewMode = .unlessEditing
        borderStyle = .none
        textColor = .darkText
        self.delegate = self
    }

    private weak var viewBorder: UIView?
    
    private weak var realDelegate: UITextFieldDelegate?
    
    /// :nodoc:
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        self.layer.cornerRadius = 6.0
        self.layer.borderColor = borderColor?.cgColor
        self.layer.borderWidth = 1

        reloadPlaceholder()

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
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: placeholderColor
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x -= 16
        return rightViewRect
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
            self.layer.borderColor = highlightedBorderColor?.cgColor
        }

        if let method = realDelegate?.textFieldDidBeginEditing(_:) {
            return method(textField)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderColor = borderColor?.cgColor

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
