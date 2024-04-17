//
//  SignupSubscriptionView.swift
//  PIA VPN-tvOS
//
//  Created by Said Rehouni on 1/4/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

import SwiftUI

struct SignupSubscriptionView: View {
    @ObservedObject var viewModel: SignupViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text(viewModel.title)
                .font(.system(size: 57))
                .bold()
                .foregroundColor(.piaOnBackground)
            
            Text(viewModel.subtitle)
                .font(.system(size: 31))
                .foregroundColor(.piaOnBackground)
            
            VStack(alignment: .leading, spacing: 40) {
                ForEach(viewModel.subscriptionOptions, id: \.option) { subscription in
                    SubscriptionOptionView(viewModel: subscription, isSelected: viewModel.selectedSubscription == subscription.option) {
                        viewModel.selectSubscription(subscription.option)
                    }
                }
            }.padding(EdgeInsets(top: 20, leading: 70, bottom: 20, trailing: 70))
            
            ActionButton(title: viewModel.subscribeButtonTitle) {
                viewModel.subscribe()
            }
            .frame(height: 66)
            .padding(EdgeInsets(top: 20, leading: 70, bottom: 20, trailing: 70))
            
            HStack(spacing: 150) {
                ForEach(viewModel.optionButtons, id: \.title) { optionButton in
                    Button {
                        optionButton.action()
                    } label: {
                        Text(optionButton.title)
                            .font(.system(size: 38))
                    }.buttonStyle(.plain)
                }
            }.frame(maxWidth: .infinity)
        }.onAppear {
            viewModel.getproducts()
        }
    }
}
