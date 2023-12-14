
import SwiftUI

struct DashboardView: View {
    let viewWidth = UIScreen.main.bounds.width
    let viewHeight = UIScreen.main.bounds.height
    
    let connectionButton: PIAConnectionButton
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                connectionButton
                .padding()
            }
            .frame(maxWidth: (viewWidth/2))
            .padding()
            
        }
        .frame(width: viewWidth, height: viewHeight)
        .background(Color.app_background)
        
        
    }
}

#Preview {
    DashboardView(connectionButton: DashboardFactory.makePIAConnectionButton())
}
