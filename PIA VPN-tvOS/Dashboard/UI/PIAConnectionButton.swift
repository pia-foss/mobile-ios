

import SwiftUI

struct PIAConnectionButton: View {
    var size: CGFloat = 160
    var lineWidth: CGFloat = 6
    
    @ObservedObject var viewModel:PIAConnectionButtonViewModel
    
    var body: some View {
        Button {
            viewModel.toggleConnection()
        } label: {
            ZStack {
                connectingRing(for: viewModel.tintColor.0)
                    .frame(width: size)
                    .opacity(viewModel.animating ? 1 : 0)
                    .animation(Animation
                        .easeOut(duration: 1)
                        .repeat(while: viewModel.animating), value: viewModel.animating)
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth))
                    .foregroundStyle(viewModel.animating ? .tertiary : .primary)
                    .foregroundColor(viewModel.tintColor.1)
                    .frame(width: size)

                Image("vpn-button")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(viewModel.tintColor.0)
                    .frame(width: (size-100), height: (size-100))
            }

        }
        .buttonStyle(.card)
        .buttonBorderShape(ButtonBorderShape.capsule)
        
    }

    
    func connectingRing(for color: Color) -> some View {
        Circle()
            .trim(from: viewModel.animating ? 0 : 1, to: viewModel.animating ? 1.5 : 1)
            .stroke(color.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .square))
            .rotationEffect(.degrees(-95))
    }
}
