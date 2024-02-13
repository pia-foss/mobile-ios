
import SwiftUI

struct QuickConnectView: View {
    @ObservedObject var viewModel: QuickConnectViewModel
    
    let rows = [ GridItem(.adaptive(minimum: 160, maximum: 160)) ]
    var body: some View {
        
        HStack(alignment: .top, spacing: 44) {
            ForEach(viewModel.servers, id: \.regionIdentifier) { item in
                DashboardFactory.makeQuickConnectButton(for: item, delegate: viewModel)
            }
        }
        .onAppear {
            viewModel.updateStatus()
        }
        
    }
}

#Preview {
    QuickConnectView(viewModel: DashboardFactory.makeQuickConnectViewModel())
}
