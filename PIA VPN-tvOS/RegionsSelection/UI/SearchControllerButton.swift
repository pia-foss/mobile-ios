//
//  SearchControllerButton.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/8/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SearchControllerButton: View {
    let buttonAction: ButtonAction
    let buttonTitle: String
    
    @FocusState var focusedSearchButton: Bool
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack(alignment: .center) {
                Spacer()
                VStack {
                    Spacer()
                    Text(buttonTitle)
                        .font(.system(size: 38, weight: .medium))
                        .padding(.horizontal, 90)
                        .padding(.vertical, 8)
                        .foregroundColor(focusedSearchButton ? .pia_on_primary : .pia_on_surface)
                        .background(focusedSearchButton ? Color.pia_primary : Color.pia_surface_container_secondary)
                        .cornerRadius(8)
                    Spacer()
                }
                .frame(height: 66)
                
                Spacer()
                
            }
            .frame(height: 150)
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Color.pia_outline, lineWidth: 2)
            )
            
        }
        .focused($focusedSearchButton)
        .buttonStyle(.borderless)
        .buttonBorderShape(ButtonBorderShape.roundedRectangle)
    }
}
