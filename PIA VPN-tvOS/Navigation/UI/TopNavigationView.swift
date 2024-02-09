//
//  LeadingSegmentedNavigationView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/6/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

/// View displayed in the Leading part of the Navigation top bar
struct LeadingSegmentedNavigationView: View {
    
    @ObservedObject var viewModel: TopNavigationViewModel
    @FocusState var focusedSection: TopNavigationViewModel.Sections?
    
    func button(for section: TopNavigationViewModel.Sections) -> some View {
        Button {
            viewModel.sectionDidUpdateSelection(to: section)

        } label: {
            Text(section.title)
                .font(.system(size: 29, weight: .medium))
                .padding(.vertical, 14)
                .padding(.horizontal, 28)
                .cornerRadius(32)
                .foregroundColor(section == viewModel.highlightedSection ? Color.black : Color.white)
                .background(Capsule().fill(
                    section == viewModel.highlightedSection ? Color.pia_primary :
                        section == viewModel.selectedSection ?
                    Color.pia_on_primary : Color.clear
                ).shadow(radius: 3))
        }
        .buttonBorderShape(.capsule)
        .buttonStyle(.borderless)
        .focused($focusedSection, equals: section)
        
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 2) {
                ForEach(viewModel.leadingSections, id: \.self) { section in
                    button(for: section)
                        .padding(6)
                        
                }
            }
            .background(Capsule().fill(Color.pia_surface_container_secondary).shadow(radius: 3))
        }
        .onChange(of: focusedSection) { _, newValue in
            viewModel.sectionDidUpdateFocus(to: newValue)
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
       
    }
        
}

/// View displayed in the Trailing part of the Navigation top bar
struct TrailingNavigationView: View {
    @ObservedObject var viewModel: TopNavigationViewModel
    @FocusState var focusedSection: TopNavigationViewModel.Sections?
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(spacing: 16) {
                ForEach(viewModel.trailingSections, id: \.self) { section in
                    Button {
                        viewModel.sectionDidUpdateSelection(to: section)
                    } label: {
                        Image(systemName: section.systemIconName)
                            .padding(12)
                            .foregroundColor(section == viewModel.highlightedSection ? Color.black : Color.white)
                            .background(
                                section == viewModel.highlightedSection 
                                ? Color.pia_primary : Color.pia_surface_container_secondary)
                            .clipShape(Circle())
                    }
                    .focused($focusedSection, equals: section)
                    .buttonBorderShape(.circle)
                    .buttonStyle(.card)
                }
            }
            
        }
        .onChange(of: focusedSection) { _, newValue in
            viewModel.sectionDidUpdateFocus(to: newValue)
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
    }
}
