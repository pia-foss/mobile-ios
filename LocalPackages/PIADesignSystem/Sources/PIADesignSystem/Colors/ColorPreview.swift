//
//  ColorPreview.swift
//  PIA VPN
//
//  Created by Diego Trevisan on 08.12.25.
//  Copyright © 2025 Private Internet Access, Inc.
//
//  This file is part of the Private Internet Access iOS Client.
//
//  The Private Internet Access iOS Client is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The Private Internet Access iOS Client is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License along with the Private
//  Internet Access iOS Client.  If not, see <https://www.gnu.org/licenses/>.
//

#if canImport(UIKit)
import UIKit
#endif

import SwiftUI

/// Preview view demonstrating PIA colors
///
/// This is a runtime representation of the PIA iOS Color design system.
/// Figma reference: https://www.figma.com/design/9fECLgfxfFunLz7eBSOYmg/-PIA--iOS---Components?node-id=1-37
@available(iOS 14.0, *)
struct ColorPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("PIA Color System")
                        .typography(.title1, color: .pia.onBackground)

                    Text("Design System Colors")
                        .typography(.body2, color: .pia.onBackground)
                }
                .padding(.vertical, 20)

                // Color Sections
                ColorSection(title: "Primary", colors: primaryColors)
                ColorSection(title: "Background", colors: backgroundColors)
                ColorSection(title: "Surface", colors: surfaceColors)
                ColorSection(title: "Inverse", colors: inverseColors)
                ColorSection(title: "Outline", colors: outlineColors)
                ColorSection(title: "Error", colors: errorColors)
                ColorSection(title: "Fixed", colors: fixedColors)
                
                GradientSection(title: "Fixed Gradients", gradients: gradientColors)

            }
            .padding()
        }
        .padding(.vertical)
        .background(Color.pia.background)
        .ignoresSafeArea()
    }
    
    private var primaryColors: [ColorInfo] {
        [
            .init(name: "Primary", color: .pia.primary, lightHex: "#037900", darkHex: "#5DDF5A"),
            .init(name: "OnPrimary", color: .pia.onPrimary, lightHex: "#FFFFFF", darkHex: "#323642")
        ]
    }
    
    private var backgroundColors: [ColorInfo] {
        [
            .init(name: "Background", color: .pia.background, lightHex: "#EEEEEE", darkHex: "#323642"),
            .init(name: "OnBackground", color: .pia.onBackground, lightHex: "#323642", darkHex: "#EEEEEE")
        ]
    }
    
    private var surfaceColors: [ColorInfo] {
        [
            .init(name: "Surface", color: .pia.surface, lightHex: "#EEEEEE", darkHex: "#323642"),
            .init(name: "SurfaceOverlay", color: .pia.surfaceOverlay, lightHex: "#1B1D22 (40%)", darkHex: "#1B1D22 (40%)"),
            .init(name: "SurfaceContainerPrimary", color: .pia.surfaceContainerPrimary, lightHex: "#FFFFFF", darkHex: "#454557"),
            .init(name: "SurfaceContainerSecondary", color: .pia.surfaceContainerSecondary, lightHex: "#D7D8D9", darkHex: "#5C6370"),
            .init(name: "OnSurface", color: .pia.onSurface, lightHex: "#323642", darkHex: "#EEEEEE"),
            .init(name: "OnSurfaceContainerPrimary", color: .pia.onSurfaceContainerPrimary, lightHex: "#5C6370", darkHex: "#D7D8D9"),
            .init(name: "OnSurfaceContainerSecondary", color: .pia.onSurfaceContainerSecondary, lightHex: "#889099", darkHex: "#A8ADB3")
        ]
    }
    
    private var inverseColors: [ColorInfo] {
        [
            .init(name: "InverseSurface", color: .pia.inverseSurface, lightHex: "#323642", darkHex: "#EEEEEE"),
            .init(name: "InverseOnSurface", color: .pia.inverseOnSurface, lightHex: "#EEEEEE", darkHex: "#323642")
        ]
    }
    
    private var outlineColors: [ColorInfo] {
        [
            .init(name: "Outline", color: .pia.outline, lightHex: "#D7D8D9", darkHex: "#889099"),
            .init(name: "OutlineVariantPrimary", color: .pia.outlineVariantPrimary, lightHex: "#889099", darkHex: "#D7D8D9")
        ]
    }
    
    private var errorColors: [ColorInfo] {
        [
            .init(name: "Error", color: .pia.error, lightHex: "#B0024C", darkHex: "#FF72A5"),
            .init(name: "OnError", color: .pia.onError, lightHex: "#FFFFFF", darkHex: "#FFFFFF")
        ]
    }
    
    private var fixedColors: [ColorInfo] {
        [
            .init(name: "ErrorContainer", color: .pia.errorContainer, lightHex: "#FEF1F5", darkHex: "#FEF1F5"),
            .init(name: "WarningContainer", color: .pia.warningContainer, lightHex: "#FEE4D3", darkHex: "#FEE4D3"),
            .init(name: "InfoContainer", color: .pia.infoContainer, lightHex: "#EDF5FE", darkHex: "#EDF5FE"),
            .init(name: "SuccessContainer", color: .pia.successContainer, lightHex: "#D9F6D5", darkHex: "#D9F6D5"),
            .init(name: "OnErrorOutline", color: .pia.onErrorOutline, lightHex: "#FF72A5", darkHex: "#FF72A5"),
            .init(name: "OnWarningOutline", color: .pia.onWarningOutline, lightHex: "#FEA754", darkHex: "#FEA754"),
            .init(name: "OnInfoOutline", color: .pia.onInfoOutline, lightHex: "#86D0FD", darkHex: "#86D0FD"),
            .init(name: "OnSuccessOutline", color: .pia.onSuccessOutline, lightHex: "#88E47B", darkHex: "#88E47B"),
            .init(name: "OnErrorContainer", color: .pia.onErrorContainer, lightHex: "#B0024C", darkHex: "#B0024C"),
            .init(name: "OnWarningContainer", color: .pia.onWarningContainer, lightHex: "#943511", darkHex: "#943511"),
            .init(name: "OnInfoContainer", color: .pia.onInfoContainer, lightHex: "#0171C4", darkHex: "#0171C4"),
            .init(name: "OnSuccessContainer", color: .pia.onSuccessContainer, lightHex: "#037900", darkHex: "#037900")
        ]
    }
    
    private var gradientColors: [GradientInfo] {
        [
            .init(name: "SurfaceStatusConnected", gradient: Color.pia.surfaceStatusConnected, startHex: "#4CB649", endHex: "#5DD5FA"),
            .init(name: "SurfaceStatusConnecting", gradient: Color.pia.surfaceStatusConnecting, startHex: "#E6B400", endHex: "#F9CF01"),
            .init(name: "SurfaceStatusError", gradient: Color.pia.surfaceStatusError, startHex: "#B2352D", endHex: "#F24458")
        ]
    }
}

@available(iOS 13.0, *)
struct ColorInfo: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let lightHex: String
    let darkHex: String
}

@available(iOS 13.0, *)
struct GradientInfo: Identifiable {
    let id = UUID()
    let name: String
    let gradient: PIAGradient
    let startHex: String
    let endHex: String
}

@available(iOS 14.0, *)
struct ColorSection: View {
    let title: String
    let colors: [ColorInfo]
    
    private let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .typography(.title2, color: .pia.onBackground)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(colors) { colorInfo in
                    ColorSwatch(
                        name: colorInfo.name,
                        color: colorInfo.color,
                        lightHex: colorInfo.lightHex,
                        darkHex: colorInfo.darkHex
                    )
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct GradientSection: View {
    let title: String
    let gradients: [GradientInfo]
    
    private let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .typography(.title2, color: .pia.onBackground)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(gradients) { gradientInfo in
                    GradientSwatch(
                        name: gradientInfo.name,
                        gradient: gradientInfo.gradient,
                        startHex: gradientInfo.startHex,
                        endHex: gradientInfo.endHex
                    )
                }
            }
        }
    }
}

@available(iOS 14.0, *)
struct ColorSwatch: View {
    let name: String
    let color: Color
    let lightHex: String
    let darkHex: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 80, height: 80)
                .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                .shadow(radius: 5, y: 2)

            Text(name)
                .typography(.subtitle2, color: .pia.onBackground)

            VStack {
                Text(lightHex)
                    .typography(.caption1, color: .pia.onBackground)
                Text(darkHex)
                    .typography(.caption1, color: .pia.onBackground)
            }
        }
    }
}

@available(iOS 14.0, *)
struct GradientSwatch: View {
    let name: String
    let gradient: PIAGradient
    let startHex: String
    let endHex: String

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [gradient.start, gradient.end]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
                .shadow(radius: 5, y: 2)

            Text(name)
                .typography(.subtitle2, color: .pia.onBackground)

            VStack {
                Text("Start: \(startHex)")
                    .typography(.caption1, color: .pia.onBackground)
                Text("End: \(endHex)")
                    .typography(.caption1, color: .pia.onBackground)
            }
        }
    }
}


@available(iOS 15.0, *)
#Preview("Light Mode") {
    ColorPreview()
        .preferredColorScheme(.light)
}


@available(iOS 15.0, *)
#Preview("Dark Mode") {
    ColorPreview()
        .preferredColorScheme(.dark)
}
