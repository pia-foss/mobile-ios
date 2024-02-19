//
//  TopNavigationView+ViewModifier.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI


extension View {
    /// Adds the top navigation bar + a custom View on the Spacing for the Title
    /// E.g: The Dashboard View (that shows the Connection states with different styles and colors depending on its value)
    func withTopNavigationBarAndTitleView(titleView: @escaping () -> some View) -> some View {
        modifier(TopNavigationBarAndTitleViewViewModifier(titleView: titleView()))
    }
    
    
    /// Adds the top navigation bar + an optional title and subtitle with the default styles
    func withTopNavigationBar(title: String? = nil, subtitle: String? = nil) -> some View {
        modifier(TopNavigationBarAndTitleWithSubtitleViewViewModifier(titleText: title, subtitleText: subtitle))
    }
}


fileprivate struct TopNavigationBarAndTitleViewViewModifier: ViewModifier {
    var titleView: any View
    
    func body(content: Content) -> some View {
        content
            .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView(), trailing: TopNavigationFactory.makeTrailingNavigationView())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AnyView(titleView)
                }
            }
        
    }
}

fileprivate struct TopNavigationBarAndTitleWithSubtitleViewViewModifier: ViewModifier {
    var titleText: String?
    var subtitleText: String?
    
    func body(content: Content) -> some View {
        content
            .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView(), trailing: TopNavigationFactory.makeTrailingNavigationView())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 16) {
                        Text(titleText ?? "")
                            .font(.system(size: 58, weight: .bold))
                            .foregroundColor(.pia_on_surface)
                        if let subtitleText {
                            Text(subtitleText)
                                .font(.system(size: 29, weight: .medium))
                                .foregroundColor(.pia_on_surface)
                        }
                        
                    }
                }
            }
    }
}


