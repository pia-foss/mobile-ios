//
//  PurchasePlanCell.swift
//  PIALibrary-iOS
//
//  Created by Davide De Rosa on 10/19/17.
//  Copyright © 2017 London Trust Media. All rights reserved.
//

import UIKit

class PurchasePlanCell: UICollectionViewCell, Restylable {
    
    // XXX
    private static let textPlaceholder = "                    "

    private static let pricePlaceholder = "             "

    @IBOutlet private weak var viewContainer: UIView!

    @IBOutlet private weak var viewHeader: UIView!

    @IBOutlet private weak var viewBestValue: UIView!
    
    @IBOutlet private weak var labelBestValue: UILabel!
    
    @IBOutlet private weak var labelPlan: UILabel!

    @IBOutlet private weak var viewSpacer: UIView!

    @IBOutlet private weak var labelPrice: UILabel!

    @IBOutlet private weak var labelDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isSelected = false
        labelBestValue.text = L10n.Welcome.Plan.bestValue
    }
    
    func fill(plan: PurchasePlan) {
        viewShouldRestyle()
        
        if plan.isDummy {
            let pendingBackgroundColor = UIColor(white: 0.95, alpha: 1.0)
            labelPlan.backgroundColor = pendingBackgroundColor
            labelDetail.backgroundColor = pendingBackgroundColor
            labelPrice.backgroundColor = pendingBackgroundColor

            labelPlan.text = PurchasePlanCell.textPlaceholder
            labelDetail.text = PurchasePlanCell.textPlaceholder
            labelPrice.text = PurchasePlanCell.pricePlaceholder
            viewBestValue.isHidden = true
        } else {
            labelPlan.backgroundColor = .clear
            labelDetail.backgroundColor = .clear
            labelPrice.backgroundColor = .clear

            labelPlan.text = plan.title
            labelDetail.text = plan.detail
            labelPrice.text = L10n.Welcome.Plan.priceFormat(plan.monthlyPriceString)
            viewBestValue.isHidden = !plan.bestValue

            if plan.bestValue {
                Theme.current.applyTitle(labelDetail, appearance: .dark)
                Theme.current.applySmallInfo(labelPrice, appearance: .dark)
            }

            accessibilityLabel = "\(plan.title), \(plan.accessibleMonthlyPriceString) \(L10n.Welcome.Plan.Accessibility.perMonth)"
        }
        viewBestValue.isHidden = !plan.bestValue
    }
    
    override var isSelected: Bool {
        didSet {
            Theme.current.applyBorder(viewContainer, selected: isSelected)
//            Theme.current.applyTitle(labelPrice, appearance:(isSelected ? .emphasis : .dark))

            if isSelected {
                Theme.current.applySolidSelection(viewHeader)
                Theme.current.applyTitle(labelPlan, appearance: .light)
                viewSpacer.isHidden = true
            } else {
                viewHeader.backgroundColor = .clear
                Theme.current.applyTitle(labelPlan, appearance: .dark)
                viewSpacer.isHidden = false
            }
        }
    }
    
    // MARK: Restylable

    func viewShouldRestyle() {
        Theme.current.applyCorner(viewBestValue, factor: 0.5)
        Theme.current.applyWarningBackground(viewBestValue)
        Theme.current.applyTag(labelBestValue, appearance: .light)
        Theme.current.applyDivider(viewSpacer)
        Theme.current.applyTitle(labelPrice, appearance: .dark)
        Theme.current.applySmallInfo(labelDetail, appearance: .dark)
    }
}
