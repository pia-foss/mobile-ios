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
    private static let bestValueContainerHeight: CGFloat = 20.0
    private static let priceBottomConstant: CGFloat = 26.0

    @IBOutlet private weak var viewContainer: UIView!
    @IBOutlet private weak var viewBestValue: UIView!
    @IBOutlet private weak var labelBestValue: UILabel!
    @IBOutlet private weak var labelPlan: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelDetail: UILabel!

    @IBOutlet private weak var unselectedPlanImageView: UIImageView!
    @IBOutlet private weak var selectedPlanImageView: UIImageView!

    @IBOutlet private weak var bestValueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var priceBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
        labelBestValue.text = L10n.Welcome.Plan.bestValue.uppercased()
        selectedPlanImageView.alpha = 0
        self.accessibilityTraits = UIAccessibilityTraits.button
        self.isAccessibilityElement = true
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
            self.accessibilityLabel = "\(plan.title) \(plan.detail) \(labelPrice.text)"
            viewBestValue.isHidden = !plan.bestValue
            if viewBestValue.isHidden {
                bestValueHeightConstraint.constant = 0
                priceBottomConstraint.constant = 0
            } else {
                bestValueHeightConstraint.constant = PurchasePlanCell.bestValueContainerHeight
                priceBottomConstraint.constant = PurchasePlanCell.priceBottomConstant
            }
            
            if plan.plan == Plan.yearly {
                Theme.current.applyTitle(labelDetail, appearance: .dark)
                Theme.current.applySmallInfo(labelPrice, appearance: .dark)
            } else {
                Theme.current.applyTitle(labelPrice, appearance: .dark)
                Theme.current.applySmallInfo(labelDetail, appearance: .dark)
            }

            self.layoutSubviews()

            accessibilityLabel = "\(plan.title), \(plan.accessibleMonthlyPriceString) \(L10n.Welcome.Plan.Accessibility.perMonth)"
        }
        viewBestValue.isHidden = !plan.bestValue
    }
    
    override var isSelected: Bool {
        didSet {
            Theme.current.applyBorder(viewContainer, selected: isSelected)
//            Theme.current.applyTitle(labelPrice, appearance:(isSelected ? .emphasis : .dark))

            if isSelected {
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedPlanImageView.alpha = 1
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedPlanImageView.alpha = 0
                })
            }
        }
    }
    
    // MARK: Restylable

    func viewShouldRestyle() {
        Theme.current.applyCorner(viewBestValue, factor: 1.0)
        Theme.current.applyWarningBackground(viewBestValue)
        Theme.current.applyBlackLabelInBox(labelBestValue)
        Theme.current.applySubtitle(labelPlan)
        Theme.current.applyTitle(labelPrice, appearance: .dark)
        Theme.current.applySubtitle(labelDetail)
    }
}
