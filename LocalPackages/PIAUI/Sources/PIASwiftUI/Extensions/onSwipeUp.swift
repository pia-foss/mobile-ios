//
//  onSwipeUp.swift
//  PIAUI
//
//  Created by Mario on 26/10/2026.
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

#if !os(tvOS)
    import SwiftUI

    public extension View {
        /// Calls `action` when the view is swiped up. While dragged, the view follows the finger; if the
        /// swipe falls short, it springs back to where it was.
        ///
        /// - Parameters:
        ///   - distance: How far up, in points, the finger must travel to trigger `action`. A quick
        ///     flick counts by where it would have ended, so a short fast swipe also triggers.
        ///   - downwardResistance: How much a drag in the wrong direction (down) is damped: the view
        ///     moves the finger's distance divided by this value. Use `1` or more: `1` follows the
        ///     finger exactly, larger values feel stiffer, like a scroll view pulled past its end.
        ///   - action: Called once when the swipe ends past `distance`.
        func onSwipeUp(
            distance: CGFloat = 24,
            downwardResistance: CGFloat = 6,
            perform action: @escaping () -> Void
        ) -> some View {
            modifier(SwipeUp(distance: distance, downwardResistance: downwardResistance, action: action))
        }
    }

    private struct SwipeUp: ViewModifier {
        let distance: CGFloat
        let downwardResistance: CGFloat
        let action: () -> Void

        @State private var dragOffset: CGFloat = 0

        func body(content: Content) -> some View {
            content
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let height = value.translation.height
                            dragOffset = height < 0 ? height : height / downwardResistance
                        }
                        .onEnded { value in
                            if min(value.translation.height, value.predictedEndTranslation.height) <= -distance {
                                action()
                            } else {
                                withAnimation(.spring()) { dragOffset = 0 }
                            }
                        }
                )
        }
    }
#endif
