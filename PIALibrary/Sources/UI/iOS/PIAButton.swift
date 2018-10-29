//
//  PIAButton.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 29/10/2018.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import Foundation
import UIKit

// UIButton with rounded corners and border to be used throughout PIA application
public class PIAButton: UIButton {
    
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
    
    func setRounded() {
        self.layer.cornerRadius = 6.0
        clipsToBounds = true
    }

    func setBorder(withSize size: CGFloat,
                   andColor color: UIColor) {
        self.layer.borderWidth = size
        self.layer.borderColor = color.cgColor
        clipsToBounds = true
    }

    func setPlain() {
        self.layer.cornerRadius = 0.0
        self.layer.borderWidth = 0.0
        self.layer.borderColor = UIColor.clear.cgColor
        clipsToBounds = true
    }
}
