
import SwiftUI
// TODO: Remove me
import PIALibrary

struct DashboardView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                DashboardConnectionButtonSection()
                .padding()
                
                Divider()
                
                DashboardFactory.makeSelectedServerView()
                    .padding()
                    
                Divider()
                
                QuickConnectSection()
//                    .frame(width: (viewWidth/2))
                
                Divider()
                
                // TODO: Remove logout button from the Dashboard
                // when we have it in the settings screen
                Button {
                    viewModel.logOut()
                } label: {
                    Text(L10n.Localizable.Menu.Logout.confirm)
                }

            }
            .frame(width: Spacing.dashboardViewWidth)
            .padding()
            
        }
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

//fileprivate struct SelectedServerSection: View {
//
//    var onRegionSelectionSectionTapped: () -> Void
//    
//    var body: some View {
//        Button {
//            onRegionSelectionSectionTapped()
//        } label: {
//            DashboardFactory.makeSelectedServerView()
//        }
//        .buttonStyle(.plain)
//        .buttonBorderShape(.roundedRectangle(radius: 4))
//    }
//}

fileprivate struct QuickConnectSection: View {
    var body: some View {
        DashboardFactory.makeQuickConnectView()
    }
}

#Preview {
    DashboardView(
        viewModel: DashboardFactory.makeDashboardViewModel())
}
