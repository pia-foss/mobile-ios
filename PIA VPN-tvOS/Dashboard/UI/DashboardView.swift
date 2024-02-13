
import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            DashboardConnectionButtonSection()
                .padding(.bottom, 80)
            
            SelectedServerSection()
                .padding(.bottom, 40)
            
            QuickConnectSection()
            
        }
        .frame(width: Spacing.dashboardViewWidth)
        
    }
}

// MARK: Dashboard sections

fileprivate struct DashboardConnectionButtonSection: View {
    var body: some View {
        HStack {
            Spacer()
            DashboardFactory.makePIAConnectionButton()
            Spacer()
        }
    }
}

fileprivate struct SelectedServerSection: View {
    var body: some View {
        DashboardFactory.makeSelectedServerView()
    }
}

fileprivate struct QuickConnectSection: View {
    var body: some View {
        DashboardFactory.makeQuickConnectView()
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardFactory.makeDashboardViewModel())
}
