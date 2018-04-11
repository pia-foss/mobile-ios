//
//  FakeSwitch.swift
//  PIA VPN
//
//  Created by Davide De Rosa on 3/1/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

class FakeSwitch: UIControl {
    private lazy var switchUnderlying = UISwitch()

    var isOn = false {
        didSet {
            switchUnderlying.isOn = isOn
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init() {
        super.init(frame: .zero)
        
        switchUnderlying.isUserInteractionEnabled = false
        addSubview(switchUnderlying)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        frame = switchUnderlying.bounds
    }
}
