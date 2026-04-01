//
//  CollectionViewAutoSizeUtils.swift
//  PIA VPN
//  
//  Created by Jose Blaya on 13/10/2020.
//  Copyright © 2020 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software 
//  without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to 
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
//  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//

import UIKit

extension UICollectionView {
    var widestCellWidth: CGFloat {
        let insets = contentInset.left + contentInset.right
        return bounds.width - insets
    }
}

class FullWidthCollectionViewCell: UICollectionViewCell {
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        // Replace the height in the target size to
        // allow the cell to flexibly compute its height
        var targetSize = targetSize
        targetSize.height = CGFloat.greatestFiniteMagnitude
        
        // The .required horizontal fitting priority means
        // the desired cell width (targetSize.width) will be
        // preserved. However, the vertical fitting priority is
        // .fittingSizeLevel meaning the cell will find the
        // height that best fits the content
        let size = super.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
        return size
    }
}

class AutoInvalidatingLayout: UICollectionViewFlowLayout {
    // Compute the width of a full width cell
    // for a given bounds
    func widestCellWidth(bounds: CGRect) -> CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        let insets = collectionView.contentInset
        let width = bounds.width - insets.left - insets.right
        
        if width < 0 { return 0 }
        else { return width }
    }
    
    // Update the estimatedItemSize for a given bounds
    func updateEstimatedItemSize(bounds: CGRect) {
        estimatedItemSize = CGSize(
            width: widestCellWidth(bounds: bounds),
            // Make the height a reasonable estimate to
            // ensure the scroll bar remains smooth
            height: 100
        )
    }

    // assign an initial estimatedItemSize by calling
    // updateEstimatedItemSize. prepare() will be called
    // the first time a collectionView is assigned
    override func prepare() {
        super.prepare()

        let bounds = collectionView?.bounds ?? .zero
        updateEstimatedItemSize(bounds: bounds)
    }
    
    // If the current collectionView bounds.size does
    // not match newBounds.size, update the
    // estimatedItemSize via updateEstimatedItemSize
    // and invalidate the layout
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else {
            return false
        }
        
        let oldSize = collectionView.bounds.size
        guard oldSize != newBounds.size else { return false }
        
        updateEstimatedItemSize(bounds: newBounds)
        return true
    }
}
