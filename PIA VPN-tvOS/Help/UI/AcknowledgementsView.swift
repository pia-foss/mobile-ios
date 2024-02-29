//
//  AcknowledgementsView.swift
//  PIA VPN-tvOS
//
//  Created by Laura S on 2/27/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct AcknowledgementsView: View {
    @ObservedObject var viewModel: AcknowledgementsViewModel
    
    var body: some View {
        
        ScrollView(.vertical) {
            Group {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.copyright.title)
                        .font(.system(size: 29, weight: .medium))
                        .foregroundColor(.pia_on_background)
                    Text(viewModel.copyright.description)
                        .font(.system(size: 29, weight: .medium))
                        .foregroundColor(.pia_on_background)
                }
                .focusable()
                Divider()
                    .frame(height: 1)
                    .background(Color.pia_on_background)
                    .padding()
                
                ForEach(viewModel.licenses, id: \.name) { license in
                    LicenseView(title: license.name, copyright: license.copyright, urlString: license.licenseURL.absoluteString) {
                        return await viewModel.getLicenseContent(for: license)
                    }
                    .focusable()
                    .padding(.vertical, 10)
                    .padding(.horizontal, 40)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.pia_on_background)
                        .padding()
                    
                }
            }.frame(width: Spacing.contentViewMaxWidth)
            
        }
        .padding(.top, 80)
        .padding(.bottom, 40)
        
    }
    
}

fileprivate struct LicenseView: View {
    
    let title: String
    let copyright: String
    let urlString: String
    let getContent: () async -> String
    
    @State private var licenseContent: String = ""
    
    var body: some View {
        itemView
            .focusable()
    }
    
    var itemView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .multilineTextAlignment(.leading)
                .font(.system(size: 38, weight: .medium))
                .foregroundColor(.pia_on_surface)
            Text(licenseContent)
                .multilineTextAlignment(.leading)
                .font(.system(size: 29))
                .foregroundColor(.pia_on_surface)
                .task {
                    licenseContent = await getContent()
                }
        }
        .frame(width: Spacing.contentViewMaxWidth)
    }
    
}
