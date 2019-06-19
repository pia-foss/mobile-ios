//
//  ViewStyles.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
//  Copyright © 2018 London Trust Media. All rights reserved.
//

import UIKit

protocol ViewStyling {
    func style(style: ViewStyle)
}

public extension ViewStyle {
    
    static let refreshControlLight = ViewStyle(backgroundColor: nil,
                                          tintColor: TextStyle.textStyle7.color,
                                          layerStyle: nil)
    
    static let refreshControlDark = ViewStyle(backgroundColor: nil,
                                              tintColor: TextStyle.textStyle6.color,
                                              layerStyle: nil)
    
}
