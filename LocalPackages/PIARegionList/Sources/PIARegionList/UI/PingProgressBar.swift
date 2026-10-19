//
//  PingProgressBar.swift
//  PIARegionList
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

#if os(iOS)
    import PIADesignSystem
    import SwiftUI
    import UIKit

    struct PingProgressBar: View {
        let phase: RegionList.PingPhase

        private var progress: CGFloat {
            switch phase {
            case .idle: 0
            case .pinging: 0.5
            case .finished: 1
            }
        }

        var body: some View {
            GeometryReader { proxy in
                LinearGradient(
                    colors: [Color(UIColor.piaGreen), Color(UIColor.piaGreenDark20), Color(UIColor.piaGreen)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: proxy.size.width * progress)
                .animation(.easeInOut(duration: RegionListStyle.animationDuration), value: progress)
            }
            .frame(height: 2)
            .accessibilityHidden(true)
        }
    }
#endif
