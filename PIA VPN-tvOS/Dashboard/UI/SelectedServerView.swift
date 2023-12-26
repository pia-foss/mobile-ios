
import SwiftUI

struct SelectedServerView: View {
    @Environment(\.colorScheme) var colorScheme
    
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
                
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.gray)
                    .frame(width: 50)
                
            }
            
        }
    }
}

