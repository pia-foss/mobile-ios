//
//  StyleGuideHelpers.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//


import UIKit

// MARK: Structs
public struct TextStyle {
    
    public let font: UIFont?
    public let color: UIColor?
    public let foregroundColor: UIColor?
    public let backgroundColor: UIColor?
    public let tintColor: UIColor?
    public let lineHeight: CGFloat?

    public init(font: UIFont?,
                color: UIColor?,
                foregroundColor: UIColor?,
                backgroundColor: UIColor?,
                tintColor: UIColor?,
                lineHeight: CGFloat? = 0) {
        self.font = font
        self.color = color
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.lineHeight = lineHeight
    }
    
}

public struct ViewStyle {
    
    let backgroundColor: UIColor?
    let tintColor: UIColor?
    let layerStyle: LayerStyle?
    
    public init(backgroundColor: UIColor?, tintColor: UIColor?, layerStyle: LayerStyle?) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.layerStyle = layerStyle
    }
    
    public struct LayerStyle {
        
        let masksToBounds: Bool?
        let cornerRadius: CGFloat?
        let borderStyle: BorderStyle?
        let shadowStyle: ShadowStyle?
        
        public init(masksToBounds: Bool?, cornerRadius: CGFloat?, borderStyle: BorderStyle?, shadowStyle: ShadowStyle?) {
            self.masksToBounds = masksToBounds
            self.cornerRadius = cornerRadius
            self.borderStyle = borderStyle
            self.shadowStyle = shadowStyle
        }
        
        public struct BorderStyle {
            let color: UIColor
            let width: CGFloat
            
            public init(color: UIColor, width: CGFloat) {
                self.width = width
                self.color = color
            }
            
        }
        
        public struct ShadowStyle {
            let color: UIColor
            let radius: CGFloat
            let offset: CGSize
            let opacity: Float
            
            public init(color: UIColor, radius: CGFloat, offset: CGSize, opacity: Float) {
                self.radius = radius
                self.color = color
                self.offset = offset
                self.opacity = opacity
            }
            
        }
        
    }
    
}

public struct TextAttributeStyle {
    
    let kern: CGFloat?
    let paragraphStyle: NSMutableParagraphStyle?
    let foregroundColor: UIColor?
    let font: UIFont?
    let link: String?
    let baselineOffset: CGFloat?
    
    public init(kern: CGFloat?, paragraphStyle: NSMutableParagraphStyle?, foregroundColor: UIColor?,
                font: UIFont?, link: String?, baselineOffset: CGFloat?) {
        self.kern = kern
        self.paragraphStyle = paragraphStyle
        self.foregroundColor = foregroundColor
        self.font = font
        self.link = link
        self.baselineOffset = baselineOffset
    }
    
    func toAttributeArray() -> [NSAttributedStringKey: Any] {
        
        var array = [NSAttributedStringKey: Any]()
        
        array[NSAttributedStringKey.kern] = kern
        array[NSAttributedStringKey.paragraphStyle] = paragraphStyle
        array[NSAttributedStringKey.foregroundColor] = foregroundColor
        array[NSAttributedStringKey.font] = font
        array[NSAttributedStringKey.link] = link
        array[NSAttributedStringKey.baselineOffset] = baselineOffset
        
        return array
        
    }
    
}

// MARK: Helper extensions
extension UIView: ViewStyling {
    
    public func style(style: ViewStyle) {
        if let backgroundColor = style.backgroundColor {
            self.backgroundColor = backgroundColor
        }
        if let tintColor = style.tintColor {
            self.tintColor = tintColor
        }
        if let layerStyle = style.layerStyle {
            if let cornerRadius = layerStyle.cornerRadius {
                self.layer.cornerRadius = cornerRadius
            }
            if let masksToBounds = layerStyle.masksToBounds {
                self.layer.masksToBounds = masksToBounds
            }
            if let borderStyle = layerStyle.borderStyle {
                self.layer.borderColor = borderStyle.color.cgColor
                self.layer.borderWidth = borderStyle.width
            }
            if let shadowStyle = layerStyle.shadowStyle {
                self.layer.applySketchShadow(color: shadowStyle.color,
                                             alpha: shadowStyle.opacity,
                                             offSet: shadowStyle.offset,
                                             radius: shadowStyle.radius)
            }
        }
    }
    
}

extension CALayer {
    func applySketchShadow(
        color: UIColor = .black,
        alpha: Float = 0.12,
        offSet: CGSize = CGSize.zero,
        blur: CGFloat = 6,
        radius: CGFloat = 2.0,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = offSet
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

extension UILabel: TextStyling {
    
    public func style(style: TextStyle) {
        font = style.font
        textColor = style.color
        if let lineHeight = style.lineHeight {
            setLineHeight(lineHeight)
        }
    }
    
}

extension UIButton: TextStyling {
    
    public func style(style: TextStyle) {
        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)
        backgroundColor = style.backgroundColor
    }
    
    public func style(style: TextStyle, for controlState: UIControlState) {
        titleLabel?.font = style.font
        setTitleColor(style.color, for: controlState)
        if let color = style.backgroundColor {
            backgroundColor = nil
            setBackgroundImage(UIImage.fromColor(color), for: controlState)
        } else {
            backgroundColor = style.backgroundColor
        }
    }
    
}

extension UITextField: TextStyling {
    
    public func style(style: TextStyle) {
        font = style.font
        textColor = style.color
        placeholderColor = style.foregroundColor
        tintColor = style.tintColor
    }
    
}

extension UITextView: TextStyling {
    
    public func style(style: TextStyle) {
        font = style.font
        textColor = style.color
    }
    
}
