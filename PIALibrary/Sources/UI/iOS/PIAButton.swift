//
//  PIAButton.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 29/10/2018.
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

import Foundation
import UIKit

public enum PIAButtonStatus {
    case normal
    case error
}

// UIButton with rounded corners and border to be used throughout PIA application
public class PIAButton: UIButton {
    
    private var isButtonImage = false
    private var edgesHaveBeenSet = false
    private var renderingModeHasBeenSet = false
    private var buttonWidth: CGFloat!
    
    private var borderColor: UIColor!
    private var style: TextStyle!
    private var currentBackgroundColor: UIColor!

    override open var isHighlighted: Bool {
        didSet {
            if currentBackgroundColor == nil {
                currentBackgroundColor = backgroundColor
            }
            backgroundColor = isHighlighted && currentBackgroundColor != nil ?
                currentBackgroundColor.withAlphaComponent(0.8) : currentBackgroundColor
        }
    }
    
    public var status: PIAButtonStatus = .normal {
        didSet { reloadButtonStatus() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    private func setupView() {
        self.layer.cornerRadius = 6.0
        clipsToBounds = true
    }
    
    public func setRounded() {
        self.layer.cornerRadius = 6.0
        clipsToBounds = true
    }

    public func setBorder(withSize size: CGFloat,
                   andColor color: UIColor) {
        self.layer.borderWidth = size
        self.borderColor = color
        self.layer.borderColor = borderColor.cgColor
        clipsToBounds = true
    }

    public func setBorder(withSize size: CGFloat,
                   andStyle style: TextStyle) {
        self.layer.borderWidth = size
        self.style = style
        if let color = style.color {
            self.borderColor = color
            self.layer.borderColor = color.cgColor
        }
        clipsToBounds = true
    }

    public func resetButton() {
        self.isButtonImage = false
        self.edgesHaveBeenSet = false
        self.renderingModeHasBeenSet = false
        self.layer.cornerRadius = 0.0
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        clipsToBounds = true
    }
    
    public func setButtonImage() {
        self.isButtonImage = true
    }
    
    private func resetEdges() {
        self.edgesHaveBeenSet = false
    }
    
    private func reloadButtonStatus() {
        checkRenderingMode()
        if status == .error {
            self.resetEdges()
            if let errorColor = TextStyle.textStyle10.color {
                self.layer.borderColor = errorColor.cgColor
                self.tintColor = errorColor
                style(style: TextStyle.textStyle10,
                      for: [])
            }
        } else {
            if let color = style.color {
                self.layer.borderColor = color.cgColor
                self.tintColor = color
                style(style: style,
                      for: [])
            } else {
                self.layer.borderColor = borderColor.cgColor
                self.tintColor = borderColor
            }
        }
    }
    
    private func checkRenderingMode() {
        if !self.renderingModeHasBeenSet,
            let imageView = imageView,
            let image = imageView.image {
            self.renderingModeHasBeenSet = true
            imageView.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
    
}

extension PIAButton {
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if self.isButtonImage,
            let imageView = imageView {
            imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: imageView.frame.width + 10)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)
            for const in self.constraints {
                if const.firstAttribute == .width {
                    if !self.edgesHaveBeenSet {
                        const.constant += imageView.frame.width
                        buttonWidth = const.constant
                        self.edgesHaveBeenSet = true
                        break
                    } else {
                        const.constant = buttonWidth
                        break
                    }
                
                }
            }
        }
        
    }

}
