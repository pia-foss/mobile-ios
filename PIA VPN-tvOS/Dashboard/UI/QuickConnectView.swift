
import SwiftUI

struct QuickConnectView: View {
    @ObservedObject var viewModel: QuickConnectViewModel
    
    let rows = [ GridItem(.adaptive(minimum: 160, maximum: 160)) ]
    var body: some View {
        VStack (alignment: .leading) {
            HStack(alignment: .top, spacing: 44) {
                ForEach(viewModel.servers, id: \.id) { item in
                    DashboardFactory.makeQuickConnectButton(for: item, delegate: viewModel)
                }
                
                if viewModel.servers.count < 4 {
                    Spacer()
                }
            }
        }
        .frame(width: Spacing.dashboardViewWidth)
        .onAppear {
            viewModel.updateStatus()
        }
        
    }
}

#Preview {
    QuickConnectView(viewModel: DashboardFactory.makeQuickConnectViewModel())
}
