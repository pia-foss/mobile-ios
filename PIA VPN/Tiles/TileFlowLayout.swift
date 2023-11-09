//
//  TileFlowLayout.swift
//  PIA VPN
//
//  Created by Jose Antonio Blaya Garcia on 09/01/2019.
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
import PIALibrary

private let separatorDecorationViewTop = "separator-top"
private let separatorDecorationViewBottom = "separator-bottom"

private struct DragDropSettings {
    static let minimumPressDuration: TimeInterval = 0.2
    static let shadowOpacity: Float = 0.8
    static let shadowRadius: CGFloat = 10
    static let springDamping: CGFloat = 0.4
    static let viewAlpha: CGFloat = 0.95
    static let viewTransform: CGAffineTransform = CGAffineTransform(scaleX: 1.2, y: 1.2)
}

final class TileFlowLayout: UICollectionViewFlowLayout {
    
    private var longPress: UILongPressGestureRecognizer!
    private var originalIndexPath: IndexPath?
    private var draggingIndexPath: IndexPath?
    private var draggingView: UIView?
    private var dragOffset = CGPoint.zero

    override func awakeFromNib() {
        super.awakeFromNib()
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationViewTop)
        register(SeparatorView.self, forDecorationViewOfKind: separatorDecorationViewBottom)
    }
    
    override func prepare() {
        super.prepare()
        self.installGestureRecognizer()
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
            if index == 0 {
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
    
    /// Remove the dragging view from the superview
    public func removeDraggingViewFromSuperView() {
        UIView.animate(withDuration: AppConfiguration.Animations.duration, animations: { [weak self] in
            self?.draggingView?.alpha = 0
        }, completion: { [weak self] finished in
            self?.draggingView?.removeFromSuperview()
            self?.draggingView = nil
        })

    }
    
    private func installGestureRecognizer() {
        if longPress == nil {
            longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPress:)))
            longPress.minimumPressDuration = DragDropSettings.minimumPressDuration
            collectionView?.addGestureRecognizer(longPress)
        }
    }
    
    @objc private func handleLongPress(longPress: UILongPressGestureRecognizer) {
        let location = longPress.location(in: collectionView!)
        switch longPress.state {
        case .began: startDragAtLocation(location)
        case .changed: updateDragAtLocation(location)
        case .ended: endDragAtLocation(location)
        default:
            break
        }
    }
    
    private func startDragAtLocation(_ location: CGPoint) {
        guard let cv = collectionView else { return }
        guard let indexPath = cv.indexPathForItem(at: location) else { return }
        guard let dataSource = cv.dataSource else { return }
        guard dataSource.collectionView!(cv, canMoveItemAt: indexPath) == true else { return }
        guard let cell = cv.cellForItem(at: indexPath) else { return }
        
        originalIndexPath = indexPath
        draggingIndexPath = indexPath
        draggingView = cell.snapshotView(afterScreenUpdates: true)
        draggingView!.frame = cell.frame
        cv.addSubview(draggingView!)
        
        dragOffset = CGPoint(x: draggingView!.center.x - location.x,
                             y: draggingView!.center.y - location.y)
        
        draggingView?.layer.shadowPath = UIBezierPath(rect: draggingView!.bounds).cgPath
        draggingView?.layer.shadowColor = UIColor.black.cgColor
        draggingView?.layer.shadowOpacity = DragDropSettings.shadowOpacity
        draggingView?.layer.shadowRadius = DragDropSettings.shadowRadius
        
        invalidateLayout()
        
        UIView.animate(withDuration: AppConfiguration.Animations.duration,
                       delay: 0,
                       usingSpringWithDamping: DragDropSettings.springDamping,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
            self.draggingView?.alpha = DragDropSettings.viewAlpha
            self.draggingView?.transform = DragDropSettings.viewTransform
        }, completion: nil)
    }

    private func updateDragAtLocation(_ location: CGPoint) {
        guard let view = draggingView else { return }
        guard let cv = collectionView else { return }
        
        view.center = CGPoint(x: location.x + dragOffset.x,
                                  y: location.y + dragOffset.y)
        
        if let newIndexPath = cv.indexPathForItem(at: location) {
            if let draggingIndexPath = draggingIndexPath {
                self.invalidateLayout()
                cv.moveItem(at: draggingIndexPath, to: newIndexPath)
            }
            draggingIndexPath = newIndexPath
        }
    }

    private func endDragAtLocation(_ location: CGPoint) {
        guard let dragView = draggingView else { return }
        guard let indexPath = draggingIndexPath else { return }
        guard let cv = collectionView else { return }
        guard let datasource = cv.dataSource else { return }
        
        let targetCenter = datasource.collectionView(cv, cellForItemAt: indexPath).center
        
        let shadowFade = CABasicAnimation(keyPath: "shadowOpacity")
        shadowFade.fromValue = 0.8
        shadowFade.toValue = 0
        shadowFade.duration = AppConfiguration.Animations.duration
        dragView.layer.add(shadowFade, forKey: "shadowFade")
        
        UIView.animate(withDuration: AppConfiguration.Animations.duration,
                       delay: 0,
                       usingSpringWithDamping: DragDropSettings.springDamping,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
            dragView.center = targetCenter
            dragView.transform = .identity
            
        }) { (completed) in
            if let original = self.originalIndexPath {
                if indexPath.compare(original) != ComparisonResult.orderedSame {
                    datasource.collectionView!(cv, moveItemAt: original, to: indexPath)
                }
                dragView.removeFromSuperview()
                self.draggingIndexPath = nil
                self.draggingView = nil
                self.invalidateLayout()

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
