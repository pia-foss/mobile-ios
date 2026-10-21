//
//  AdaptiveSplitViewController.swift
//  PIA VPN
//
//  Created by Mario on 05/06/26.
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

/// A `UISplitViewController` that adapts its split behavior to the available window width.
///
/// On Mac Catalyst and iPad multitasking / Stage Manager the horizontal size class stays `.regular`
/// however narrow the window is, so the system never collapses the sidebar on its own. Watching our
/// own width lets us switch between the modes below; iPhone is always narrow:
/// - **wide** (≥ `narrowWidthThreshold`): `.tile` behavior — the sidebar sits beside the content
///   (the default behavior).
/// - **narrow** (< `narrowWidthThreshold`): `.overlay` behavior with the sidebar hidden — content
///   takes the full width and the sidebar slides over it when shown.
final class AdaptiveSplitViewController: UISplitViewController {

    /// Window width (in points) below which the sidebar collapses into a hidden overlay.
    private let narrowWidthThreshold: CGFloat = 700

    private enum LayoutMode {
        case wide
        case narrow
    }

    private var currentLayoutMode: LayoutMode?

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateLayoutMode(for: view.bounds.width)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayoutMode(for: size.width)
    }

    /// Re-applies the split behavior only when crossing the threshold, so we don't override the
    /// user's manual show/hide of the sidebar (via the dashboard menu button) while staying in the
    /// same mode.
    private func updateLayoutMode(for width: CGFloat) {
        guard width > 0 else { return }
        let isNarrow = traitCollection.userInterfaceIdiom == .phone || width < narrowWidthThreshold
        let newMode: LayoutMode = isNarrow ? .narrow : .wide
        guard newMode != currentLayoutMode else { return }
        currentLayoutMode = newMode

        switch newMode {
        case .wide:
            preferredSplitBehavior = .tile
            preferredDisplayMode = .oneBesideSecondary
        case .narrow:
            preferredSplitBehavior = .overlay
            preferredDisplayMode = .secondaryOnly
        }
    }
}
