import PIAAssetsWidget
import PIALibrary
import PIALocalizations
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
internal struct PIAConnectionView: View {

    private let context: ActivityViewContext<PIAConnectionAttributes>
    private let showProtocol: Bool
    private let localizedRegionText = L10n.Widget.LiveActivity.Region.title
    private let localizedProtocolText = L10n.Widget.LiveActivity.SelectedProtocol.title

    init(context: ActivityViewContext<PIAConnectionAttributes>, showProtocol: Bool = false) {
        self.context = context
        self.showProtocol = showProtocol
    }

    var body: some View {
        HStack {
            HStack {
                PIACircleImageView(size: 24, image: Image(context.state.regionFlag), contentMode: .fill)
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
                        PIACircleImageView(size: 24, image: Asset.greenCheckmark.swiftUIImage)
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

                PIAToggleButton(size: 54, isConnected: context.state.connected)
            }
        }
    }
}
