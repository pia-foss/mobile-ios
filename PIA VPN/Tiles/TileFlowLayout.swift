//
//  TileFlowLayout.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
//  Copyright © 2019 London Trust Media. All rights reserved.
//

import UIKit
import PIALibrary

private let separatorDecorationView = "separator"

final class TileFlowLayout: UICollectionViewFlowLayout {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationView)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect) ?? []
        let lineWidth = self.minimumLineSpacing
        
        var decorationAttributes: [UICollectionViewLayoutAttributes] = []
        for layoutAttribute in layoutAttributes {
            let separatorAttribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: separatorDecorationView,
                                                                      with: layoutAttribute.indexPath)
            let cellFrame = layoutAttribute.frame
            separatorAttribute.frame = CGRect(x: cellFrame.origin.x,
                                              y: cellFrame.origin.y - lineWidth,
                                              width: cellFrame.size.width,
                                              height: lineWidth)
            separatorAttribute.zIndex = Int.max
            decorationAttributes.append(separatorAttribute)
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
