//
//  TileFlowLayout.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

private let separatorDecorationViewTop = "separator-top"
private let separatorDecorationViewBottom = "separator-bottom"

final class TileFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationViewTop)
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationViewBottom)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []
        let lineWidth = self.minimumLineSpacing
        
        var decorationAttributes: [UICollectionViewLayoutAttributes] = []
        for (index, layoutAttribute) in layoutAttributes.enumerated() {
            //bottom
            let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: separatorDecorationViewBottom,
                                                                      with: layoutAttribute.indexPath)
            let cellFrame = layoutAttribute.frame
            separatorAttribute.frame = CGRect(x: cellFrame.origin.x,
                                              y: cellFrame.origin.y + cellFrame.size.height - lineWidth,
                                              width: cellFrame.size.width,
                                              height: lineWidth)
            separatorAttribute.zIndex = Int.max
            decorationAttributes.append(separatorAttribute)
            
            //top
            if layoutAttributes.count == 1 || index == 0 {
                let separatorAttributeTop = UICollectionViewLayoutAttributes(forDecorationViewOfKind: separatorDecorationViewTop,
                                                                             with: layoutAttribute.indexPath)
                let cellFrameTop = layoutAttribute.frame
                separatorAttributeTop.frame = CGRect(x: cellFrameTop.origin.x,
                                                     y: cellFrame.origin.y,
                                                     width: cellFrameTop.size.width,
                                                     height: lineWidth)
                separatorAttributeTop.zIndex = Int.max - 1
                decorationAttributes.append(separatorAttributeTop)
            }

        }
        
        return layoutAttributes + decorationAttributes
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        if let collectionView = collectionView {
            for subview in collectionView.subviews where subview is UICollectionReusableView {
                subview.backgroundColor = Theme.current.palette.appearance == .dark ?
                    UIColor.piaGrey10 :
                    UIColor.piaGrey2
            }

        }
    }
}

private final class SeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = Theme.current.palette.appearance == .dark ?
            UIColor.piaGrey10 :
            UIColor.piaGrey2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        self.frame = layoutAttributes.frame
    }
}
