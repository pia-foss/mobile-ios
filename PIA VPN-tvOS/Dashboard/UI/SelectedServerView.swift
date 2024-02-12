
import SwiftUI

struct SelectedServerView: View {
    @Environment(\.colorScheme) var colorScheme
    @FocusState var isButtonFocused: Bool
    
    @ObservedObject var viewModel: SelectedServerViewModel
    
    var body: some View {
    
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(viewModel.selectedSeverSectionTitle)
                    .font(.callout)
                Text(viewModel.serverName)
                    .font(.caption)
            }
            
            Spacer()
            
            HStack(alignment: .center) {
                if colorScheme == .light {
                    Image.map
                } else {
                    Image.map
                        .blendMode(.hardLight)
                }
                
                Image(systemName: "ellipsis")
                    .foregroundStyle(Color.pia_on_surface)
                    .frame(width: 50)
                
            }
            
        }
    }
}

