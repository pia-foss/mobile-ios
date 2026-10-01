//
//  UIView+Fold.swift
//  PIA VPN
//
//  Copyright © 2026 Private Internet Access, Inc.
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

// Isolated because UIHingeInteraction and reservedRegions fail to compile for Catalyst on the 27.1 seed SDK.
#if !targetEnvironment(macCatalyst)
    extension UIView {
        // A book-style fold splitting this view into two pages at least 320 pt wide, the active one preferred.
        @available(iOS 27.1, *)
        func bookFold(includingInactive: Bool) -> UIView.ReservedRegion? {
            let minimumPageWidth: CGFloat = 320
            let folds = reservedRegions(kind: .division, options: includingInactive ? .includeInactive : []).filter { region in
                region.frame.height > region.frame.width
                    && region.frame.minX >= minimumPageWidth
                    && bounds.width - region.frame.maxX >= minimumPageWidth
            }
            return folds.first(where: \.isActive) ?? folds.first
        }

        // Reserved regions drive the layout; the hinge only asks for a new layout pass.
        func relayoutOnHingeChange() {
            if #available(iOS 27.1, *) {
                addInteraction(UIHingeInteraction { [weak self] _, _ in self?.setNeedsLayout() })
            }
        }
    }
#endif
