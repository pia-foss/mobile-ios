
import SwiftUI

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            ConnectionStateBar(tintColor: viewModel.connectionTintColor.connectionBarTint)
            Spacer()
            DashboardConnectionButtonSection()
                .padding(.bottom, 80)
            
            SelectedServerSection()
                .padding(.bottom, 40)
            
            QuickConnectSection()
                .frame(width: Spacing.dashboardViewWidth)
            Spacer()
        }
        .withTopNavigationBarAndTitleView {
            // View for the Title section of the Navigation bar
            ConnectionStateTitle(title: viewModel.connectionTitle, tintColor: viewModel.connectionTintColor.titleTint)
        }
    }
}

// MARK: Dashboard sections

fileprivate struct DashboardConnectionButtonSection: View {
    var body: some View {
        DashboardFactory.makePIAConnectionButton()
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

fileprivate struct ConnectionStateTitle: View {
    let title: String
    let tintColor: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 57, weight: .bold))
            .foregroundColor(tintColor)
    }
}


fileprivate struct ConnectionStateBar: View {
    let tintColor: Color
    
    var body: some View {
        Rectangle().fill(tintColor)
            .frame(width: Spacing.screenWidth, height: 10)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardFactory.makeDashboardViewModel())
}
