//
//  DedicatedIpDetailsView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 14/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct DedicatedIpDetailsView: View {
    private let dedicatedIPStats: [DedicatedIpData]
    private let actionButtonStyle: ActionButtonStyle
    @State private var shouldShowConfirmDialog = false
    
    private let onDeleteDIPAction: () -> Void
    
    init(dedicatedIPStats: [DedicatedIpData], onDeleteDIPAction: @escaping () -> Void) {
        self.dedicatedIPStats = dedicatedIPStats
        self.actionButtonStyle = ActionButtonStyle(
            focusedColor: .piaError20,
            focusedTitleColor: .piaOnError,
            unfocusedColor: .piaSurfaceContainerSecondary,
            unfocusedTitleColor: .piaOnSurface,
            titleAlignment: .leading,
            titlePadding: EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        
        self.onDeleteDIPAction = onDeleteDIPAction
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            ForEach(dedicatedIPStats, id: \.id) { title in
                                HStack {
                                    Text(title.title)
                                        .font(.system(size: 38))
                                        .foregroundStyle(.piaOnSurface)
                                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            ForEach(dedicatedIPStats, id: \.id) { title in
                                HStack {
                                    Text(title.description)
                                        .font(.system(size: 38))
                                        .foregroundStyle(.piaOnSurfaceContainerPrimary)
                                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                            }
                        }
                    }
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(L10n.Localizable.Settings.Dedicatedip.Stats.quickAction)
                            .font(.system(size: 38))
                            .foregroundStyle(.piaSurfaceContainerSecondary)
                        ActionButton(title: L10n.Localizable.Settings.Dedicatedip.Stats.Delete.button, style: actionButtonStyle) {
                            shouldShowConfirmDialog = true
                        }.frame(height: 55)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 60, leading: 80, bottom: 0, trailing: 100))
                
                Image.onboarding_signin_world
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
            }
        }.padding(EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 0))
            .alert(L10n.Localizable.Settings.Dedicatedip.Stats.Delete.Alert.title, isPresented: $shouldShowConfirmDialog, actions: {
                    Button(role: .destructive) {
                        onDeleteDIPAction()
                    } label: {
                        Text(L10n.Localizable.Settings.Dedicatedip.Stats.Delete.Alert.delete)
                    }
                }, message: {
                    Text(L10n.Localizable.Settings.Dedicatedip.Stats.Delete.Alert.message)
            })
    }
}

