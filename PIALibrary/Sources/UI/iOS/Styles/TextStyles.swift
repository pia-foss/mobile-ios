//
//  TextStyles.swift
//  PIALibrary-iOS
//
//  Created by Jose Antonio Blaya Garcia on 3/9/18.
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

/// MARK: Helper protocols
protocol TextStyling {
    func style(style: TextStyle)
}

public extension TextStyle {
    
    static let textStyle1 = TextStyle(
        font: UIFont.regularFontWith(size: 18),
        color: UIColor.piaWhite,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyle2 = TextStyle(
        font: UIFont.regularFontWith(size: 18),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyle3 = TextStyle(
        font: UIFont.regularFontWith(size: 18),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyle4 = TextStyle(
        font: UIFont.regularFontWith(size: 18),
        color: UIColor.piaGreenDark20,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyle5 = TextStyle(
        font: UIFont.regularFontWith(size: 18),
        color: UIColor.piaRed,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyle6 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.white,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )
    
    static let textStyle6Medium = TextStyle(
        font: UIFont.mediumFontWith(size: 14),
        color: UIColor.white,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )

    static let textStyle7 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )

    static let textStyle8 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )

    static let textStyle9 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaGreenDark20,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )
    
    static let textStyle9Medium = TextStyle(
        font: UIFont.mediumFontWith(size: 14),
        color: UIColor.piaGreenDark20,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )

    static let textStyle10 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaRed,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )

    static let textStyle11 = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.white,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )

    static let textStyle12 = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )

    static let textStyle13 = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )

    static let textStyle14 = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.piaGreenDark20,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )

    static let textStyle15 = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.piaRed,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )
    
    static let textStyle16 = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaWhite,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 15
    )
    
    static let textStyle17 = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 15
    )
    
    static let textStyle18 = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 15
    )
    
    static let textStyle19 = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaGreenDark20,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 15
    )
    
    static let textStyle20 = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaRed,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 15
    )
    
    static let textStyle21 = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )
    
    static let versionNumberStyle = TextStyle(
        font: UIFont.regularFontWith(size: 14),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 18
    )
    
    static let ipTextStyle = TextStyle(
        font: UIFont.regularFontWith(size: 12),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 16
    )

    static let ipTitleTextStyle = TextStyle(
        font: UIFont.regularFontWith(size: 10),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 10
    )

    static let textStyle22 = TextStyle(
        font: UIFont.mediumFontWith(size: 26),
        color: UIColor.piaWhite,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )
    
    static let textStyle23 = TextStyle(
        font: UIFont.mediumFontWith(size: 26),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )
    
    static let textStyleSubscriptionInformation = TextStyle(
        font: UIFont.regularFontWith(size: 16),
        color: UIColor.piaGrey4,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )
    
    static let textStyleCardTitleDark = TextStyle(
        font: UIFont.mediumFontWith(size: 20),
        color: UIColor.piaWhite,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )

    static let textStyleCardTitleLight = TextStyle(
        font: UIFont.mediumFontWith(size: 20),
        color: UIColor.piaGrey6,
        foregroundColor: nil,
        backgroundColor: nil,
        tintColor: nil,
        lineHeight: 20
    )


    struct Buttons {
        
        public static let piaGreenButton = TextStyle(
            font: UIFont.regularFontWith(size: 14),
            color: UIColor.white,
            foregroundColor: nil,
            backgroundColor: UIColor.piaGreenDark20,
            tintColor: nil
        )
        
        public static let piaPlainTextButton = TextStyle(
            font: UIFont.regularFontWith(size: 14),
            color: nil,
            foregroundColor: nil,
            backgroundColor: nil,
            tintColor: nil
        )
        
        public static let piaSmallPlainTextButton = TextStyle(
            font: UIFont.regularFontWith(size: 12),
            color: nil,
            foregroundColor: nil,
            backgroundColor: nil,
            tintColor: nil
        )
        
    }

}
