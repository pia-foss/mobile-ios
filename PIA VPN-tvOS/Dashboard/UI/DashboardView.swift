
import SwiftUI

struct DashboardView: View {
    let viewWidth = UIScreen.main.bounds.width
    let viewHeight = UIScreen.main.bounds.height
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                DashboardConnectionButtonSection()
                .padding()
                
                Divider()
                
                SelectedServerSection(onRegionSelectionSectionTapped: viewModel.regionSelectionSectionWasTapped)
                    .padding()
                    
                Divider()
                
                QuickConnectSection()
                    .frame(width: (viewWidth/2))
                
                Divider()
                
                // TODO: Remove logout button from the Dashboard
                // when we have it in the settings screen
                Button {
                    viewModel.logOut()
                } label: {
                    Text(L10n.Localizable.Menu.Logout.confirm)
                }

            }
            .frame(maxWidth: (viewWidth/2))
            .padding()
            
        }
        .frame(width: viewWidth, height: viewHeight)
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

    var onRegionSelectionSectionTapped: () -> Void
    
    var body: some View {
        Button {
            onRegionSelectionSectionTapped()
        } label: {
            DashboardFactory.makeSelectedServerView()
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.roundedRectangle(radius: 4))
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
