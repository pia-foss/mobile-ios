
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
internal struct PIAConnectionView: View {
    
    internal let context: ActivityViewContext<PIAConnectionAttributes>
    internal let showProtocol: Bool
    
    init(context: ActivityViewContext<PIAConnectionAttributes>, showProtocol: Bool = false) {
        self.context = context
        self.showProtocol = showProtocol
    }
    
    var body: some View {
        HStack {
            HStack {
                PIACircleImageView(size: 24, image: context.state.regionFlag)
                VStack(alignment: .leading) {
                    Text("Region")
                        .font(.caption)
                    Text(context.state.regionName)
                        .font(.caption)
                        .bold()
                }
                if showProtocol {
                    
                    HStack {
                        Spacer()
                        PIACircleImageView(size: 24, image: "green-checkmark")
                        VStack(alignment: .leading) {
                            Text("Protocol")
                                .font(.caption)
                            Text(context.state.vpnProtocol)
                                .font(.caption)
                                .bold()
                        }
                        Spacer()
                    }
                } else {
                    Spacer()
                }
                
                PIACircleImageView(size: 44, image: "connect-button")
            }
        }
        
    }
}

