//
//  NavigationLogoView.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 31/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

public class NavigationLogoView: UIView {
    private let imvLogo: UIImageView
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override init(frame: CGRect) {
        imvLogo = UIImageView(image: Theme.current.palette.logo)
        super.init(frame: .zero)
        
        addSubview(imvLogo)
        
        //        backgroundColor = .orange
        //        imvLogo.backgroundColor = .green
        imvLogo.contentMode = .scaleAspectFit
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //        let navBar = navigationBar()
        let imageLogo = imvLogo.image!
        var imageSize = imageLogo.size
        //        if !Macros.isDevicePad {
        let logoRatio: CGFloat = imageLogo.size.width / imageLogo.size.height
        imageSize.width = min(imageLogo.size.width, 200.0)
        imageSize.height = imageSize.width / logoRatio
        //        }
        
        var logoFrame: CGRect = .zero
        logoFrame.origin.x = -imageSize.width / 2.0
        logoFrame.origin.y = -imageSize.height / 2.0
        logoFrame.size = imageSize
        imvLogo.frame = logoFrame.integral
    }
    
    private func navigationBar() -> UINavigationBar {
        var parent = superview
        while (parent != nil) {
            if let navBar = parent as? UINavigationBar {
                return navBar
            }
            parent = parent?.superview
        }
        fatalError("Not subview of a UINavigationBar")
    }
}
