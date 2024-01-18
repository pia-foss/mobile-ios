
import SwiftUI

struct QuickConnectView: View {
    @ObservedObject var viewModel: QuickConnectViewModel
    
    let rows = [ GridItem(.adaptive(minimum: 80)) ]
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                ForEach(viewModel.servers, id: \.regionIdentifier) { item in
                    DashboardFactory.makeQuickConnectButton(for: item, delegate: viewModel)
                }
            }
        }.onAppear {
            viewModel.updateStatus()
        }
        
    }
}

#Preview {
    QuickConnectView(viewModel: DashboardFactory.makeQuickConnectViewModel())
}
