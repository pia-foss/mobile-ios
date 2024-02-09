//
//  FormTextFieldsView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct FormTextFieldsView: View {
    enum FocusedField: Hashable {
        case username, password
    }
    
    @Binding var username: String
    @Binding var password: String
    @FocusState var focus: FocusedField?
    
    let onSubmittedForm: () -> Void
    
    var body: some View {
        VStack {
            TextField(
                L10n.Localizable.Tvos.Login.Placeholder.username,
                text: $username,
                prompt: Text(L10n.Localizable.Tvos.Login.Placeholder.username)
            )
            .textFieldStyle(TextFieldStyleModifier())
            .frame(width: 510, height: 66)
            .focused($focus, equals: .username)
            
            SecureField(
                L10n.Localizable.Tvos.Login.Placeholder.password,
                text: $password,
                prompt: Text(L10n.Localizable.Tvos.Login.Placeholder.password)
            )
            .textFieldStyle(TextFieldStyleModifier())
            .frame(width: 510, height: 66)
            .focused($focus, equals: .password)
            .onSubmit {
                onSubmittedForm()
            }
        }
    }
}
