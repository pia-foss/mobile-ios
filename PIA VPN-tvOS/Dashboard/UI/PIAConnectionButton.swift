

import SwiftUI


struct PIAConnectionButton: View {
    var size: CGFloat = 256
    var lineWidth: CGFloat = 6
    
    @FocusState var isFocused: Bool
    var animation: Animation {
        Animation.linear
    }
    
    @ObservedObject var viewModel:PIAConnectionButtonViewModel
    
    var body: some View {
        Button {
            viewModel.toggleConnection()
        } label: {
            HStack {
                Spacer()
                ZStack {
                    animatedRing(with: viewModel.tintColor)
                    Circle()
                        .fill(Color.pia_background)
                        .frame(width: size - lineWidth)
                    
                    if !viewModel.animating {
                        connectionStatusOuterRing()
                    }
                    connectionStatusInnerImage()
                }
                .frame(width: size + 40, height: size + 40)
                .scaleEffect(isFocused  ? 1.15 : 1)
                .animation(.easeOut, value: isFocused)
                Spacer()
            }
            .frame(width: Spacing.screenWidth)
            
        }
        .focused($isFocused)
        .buttonStyle(BasicButtonStyle())
        .buttonBorderShape(ButtonBorderShape.circle)
        .alert(viewModel.errorAlertTitle, isPresented: $viewModel.isShowingErrorAlert) {
            Button(viewModel.errorAlertCloseActionTitle, role: .cancel) {
                
            }
            // TODO: Localize
            Button("Retry", role: .none) {
                viewModel.toggleConnection()
            }
        } message: {
            // TODO: Localize
            Text("Please check your internet connection and try again")
        }
    }
    
    func connectionStatusInnerImage() -> some View {
        Image.connect_inner_button
            .foregroundColor(viewModel.animating ? viewModel.tintColor : isFocused ? Color.pia_background : viewModel.tintColor)
            .frame(width: 128, height: 128)
    }
    
    func connectionStatusOuterRing() -> some View {
        Circle()
            .fill(isFocused ? viewModel.tintColor : Color.pia_background)
            .stroke(viewModel.tintColor, lineWidth: lineWidth)
            .frame(width: size)
    }
    
    func animatedRing(with color: Color) -> some View {
        Circle()
            .trim(from: viewModel.animating ? 0 : 1, to: viewModel.animating ? 1.5 : 1)
            .stroke(color.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .square))
            .rotationEffect(.degrees(-95))
            .glow(color: viewModel.tintColor, radius: 36, opacity: 0.6)
            .frame(width: size)
            .opacity(viewModel.animating ? 1 : 0)
            .animation(Animation
                .easeInOut(duration: 0.8)
                .repeat(while: viewModel.animating), value: viewModel.animating)
        
    }
}



