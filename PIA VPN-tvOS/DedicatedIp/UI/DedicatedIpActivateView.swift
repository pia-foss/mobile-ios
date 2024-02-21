//
//  DedicatedIpActivateView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 12/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct DedicatedIpActivateView: View {
    @State private var token = ""
    var shouldShowErrorMessage: Binding<Bool>
    
    private let onActivateDIPAction: (String) -> Void
    
    init(shouldShowErrorMessage: Binding<Bool>, onActivateDIPAction: @escaping (String) -> Void) {
        self.shouldShowErrorMessage = shouldShowErrorMessage
        self.onActivateDIPAction = onActivateDIPAction
    }
    
    var body: some View {
        VStack {
            VStack {
                VStack(spacing: 20) {
                    Text(L10n.Localizable.Settings.Dedicatedip.title1)
                        .font(.system(size: 76))
                        .foregroundStyle(.piaOnSurface)
                        .bold()
                    
                    Text(L10n.Localizable.Settings.Dedicatedip.subtitle)
                        .font(.system(size: 29))
                        .foregroundStyle(.piaOnSurfaceContainerSecondary)
                        .multilineTextAlignment(.center)
                }.padding(EdgeInsets(top: 80, leading: 0, bottom: 0, trailing: 0))
                
                TextField(
                    L10n.Localizable.Settings.Dedicatedip.placeholder,
                    text: $token,
                    prompt: Text(L10n.Localizable.Settings.Dedicatedip.placeholder)
                )
                .textFieldStyle(TextFieldStyleModifier())
                .frame(width: 600, height: 50)
                .padding(EdgeInsets(top: 100, leading: 0, bottom: 100, trailing: 0))
                
                ActionButton(title: L10n.Localizable.Settings.Dedicatedip.button) {
                    onActivateDIPAction(token)
                }
                .frame(width: 510, height: 66)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .alert(L10n.Localizable.Settings.Dedicatedip.Alert.Failure.title, isPresented: shouldShowErrorMessage, actions: {
                Button(L10n.Localizable.Global.ok) {}
            }, message: {
                    Text(token.isEmpty 
                         ? L10n.Localizable.Settings.Dedicatedip.Alert.Failure.Message.empty
                         : L10n.Localizable.Settings.Dedicatedip.Alert.Failure.message)
        })
    }
}
