//
//  TopNavigationView+ViewModifier.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/14/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct TopNavigationBarAndTitleViewViewModifier: ViewModifier {
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

struct TopNavigationBarViewModifier: ViewModifier {
    var titleText: String?
    
    func body(content: Content) -> some View {
            content
            .navigationBarItems(leading: TopNavigationFactory.makeLeadingSegmentedNavigationView(), trailing: TopNavigationFactory.makeTrailingNavigationView())
            .navigationTitle(Text(titleText ?? ""))
        
    }
}


extension View {
    func withTopNavigationBarAndTitleView(titleView: @escaping () -> some View) -> some View {
        modifier(TopNavigationBarAndTitleViewViewModifier(titleView: titleView()))
    }
    
    func withTopNavigationBar(with title: String?) -> some View {
        modifier(TopNavigationBarViewModifier(titleText: title))
    }
}
