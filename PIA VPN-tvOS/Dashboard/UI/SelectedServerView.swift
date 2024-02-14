
import SwiftUI

struct SelectedServerView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isButtonFocused: Bool
    
    @ObservedObject var viewModel: SelectedServerViewModel
    
    private func buttonView() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(viewModel.iconImageNameFor(focused: isButtonFocused))
                .resizable()
                .frame(width: 80, height: 80)
            VStack(alignment: .leading) {
                Text(viewModel.selectedSeverTitle)
                    .font(.system(size: 29, weight: .medium))
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface_container_secondary)
                Text(viewModel.selectedServerSubtitle)
                    .font(.system(size: 31, weight: .bold))
                    .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
                    .lineLimit(nil)
            }
            .padding(.leading, 22)
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .foregroundColor(isButtonFocused ? .pia_on_primary : .pia_on_surface)
                .frame(width: 52)
        }
        .padding(.leading, 30)
    }
    
    var body: some View {
        VStack {
            Button {
                viewModel.selectedServerSectionWasTapped()
            } label: {
                buttonView()
            }
            .background(isButtonFocused ? Color.pia_primary : Color.pia_surface_container_primary)
            .clipShape(RoundedRectangle(cornerSize: Spacing.tileCornerSize))
            .buttonStyle(BasicButtonStyle())
            .focused($isButtonFocused)
            .buttonBorderShape(.roundedRectangle(radius: Spacing.tileBorderRadius))
            
        }
     
    }
}

