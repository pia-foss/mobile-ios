//
//  LoginLoadingView.swift
//  PIASwiftUI
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

#if os(tvOS)
    import PIAAssetsTV
    import SwiftUI

    public struct LoginLoadingView: View {
        public init() {}

        public var body: some View {
            VStack {
                VStack(alignment: .center, spacing: 70) {
                    Asset.loadingPiaBrand.swiftUIImage
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.74)
                }
            }
        }
    }
#endif
