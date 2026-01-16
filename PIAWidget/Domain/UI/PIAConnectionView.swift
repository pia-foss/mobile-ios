
import SwiftUI
import WidgetKit
import PIALibrary

@available(iOSApplicationExtension 16.1, *)
internal struct PIAConnectionView: View {
    
    internal let context: ActivityViewContext<PIAConnectionAttributes>
    internal let showProtocol: Bool
    let localizedRegionText = L10n.Localizable.Widget.LiveActivity.Region.title
    let localizedProtocolText = L10n.Localizable.Widget.LiveActivity.SelectedProtocol.title
    
    init(context: ActivityViewContext<PIAConnectionAttributes>, showProtocol: Bool = false) {
        self.context = context
        self.showProtocol = showProtocol
    }
    
    var body: some View {
        HStack {
            HStack {
                PIACircleImageView(size: 24, image: context.state.regionFlag, contentMode: .fill)
                VStack(alignment: .leading) {
                    Text(localizedRegionText)
                        .font(.caption)
                        .foregroundColor(.white)
                    Text(context.state.regionName)
                        .font(.caption)
                        .foregroundColor(.white)
                        .bold()
                }
                if showProtocol && context.state.connected {
                    HStack {
                        Spacer()
                        PIACircleImageView(size: 24, image: "green-checkmark")
                        VStack(alignment: .leading) {
                            Text(localizedProtocolText)
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(context.state.vpnProtocol)
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                        Spacer()
                    }
                } else {
                    Spacer()
                }
                
                Link(destination: URL(string: AppConstants.Widget.connect)!) {
                    PIACircleImageView(
                        size: 54,
                        image: context.state.connected ? "connected-button" : "disconnected-button"
                    )
                }
            }
        }
        
    }
}

