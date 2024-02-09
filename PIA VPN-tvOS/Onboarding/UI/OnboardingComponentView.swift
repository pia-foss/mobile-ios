//
//  OnboardingComponentView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 6/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingComponentStytle {
    let headerImage: Image?
    let headerSpacing: CGFloat
    let backgroundImage: Image
    let buttonsEdgeInsets: EdgeInsets
}

struct OnboardingComponentView: View {
    private let viewModel: OnboardingComponentViewModelType
    private let style: OnboardingComponentStytle
    
    init(viewModel: OnboardingComponentViewModelType, style: OnboardingComponentStytle) {
        self.viewModel = viewModel
        self.style = style
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: style.headerSpacing) {
                if let headerImage = style.headerImage {
                    headerImage
                }
                Text(viewModel.title)
                    .font(.system(size: 57))
                    .bold()
                    .fixedSize(horizontal: false, vertical: true)
                if let subtitle = viewModel.subtitle {
                    Text(subtitle)
                        .font(.system(size: 31))
                }
                
                VStack {
                    ForEach(viewModel.buttons, id: \.title) { button in
                        ActionButton(
                            title: button.title,
                            action: { button.action()
                            }
                        )
                        .frame(width: 510, height: 66)
                    }
                }
                .padding(style.buttonsEdgeInsets)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
            
            style.backgroundImage
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
        }
    }
}
