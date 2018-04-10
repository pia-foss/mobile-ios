//
//  InvalidatingFlowLayout.swift
//  PIALibrary
//
//  Created by Davide De Rosa on 12/25/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class InvalidatingFlowLayout: UICollectionViewFlowLayout {
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let flowContext = context as? UICollectionViewFlowLayoutInvalidationContext else {
            return context
        }
        guard let collectionView = self.collectionView else {
            return context
        }
//        flowContext.invalidateFlowLayoutDelegateMetrics = (
//            (newBounds.size.width != collectionView.bounds.size.width) ||
//            (newBounds.size.height != collectionView.bounds.size.height)
//        )
        flowContext.invalidateFlowLayoutDelegateMetrics = (newBounds.size != collectionView.bounds.size)
        return flowContext
    }
}
