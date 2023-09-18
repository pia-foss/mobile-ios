
import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.1, *)
internal struct PIAConnectionView: View {

    internal let context: ActivityViewContext<PIAConnectionAttributes>

    init(context: ActivityViewContext<PIAConnectionAttributes>) {
        self.context = context
    }

    var body: some View {
        let connected = context.state.connected ? "Connected" : "Disconnected"
        return HStack(spacing: 0) {
            VStack {
                Text("Region")
                    .italic()
                    .font(.caption)
                    .foregroundColor(Color(uiColor: UIColor.lightGray))
                Divider()
                    .cornerRadius(0.0)
                    .frame(height: 2.0)
                    .background(
                        LinearGradient(colors: [Color.clear, Color("AccentColor")], startPoint: .leading, endPoint: .trailing)
                    )
              Text("\(context.state.regionName)")
                    .foregroundColor(Color.white)
                    .font(.caption)
                    .bold()
            }
            VStack {
                Text("\(connected)")
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: 30.0)
                    .foregroundColor(Color.white)
                    .background(Color("AccentColor"))
                    .cornerRadius(30.0 / 2.0)
                    .textCase(.uppercase)
                    .bold()
            }
            VStack {
                Text("Protocol")
                    .italic()
                    .font(.caption)
                    .foregroundColor(Color(uiColor: UIColor.lightGray))
                Divider()
                    .cornerRadius(0.0)
                    .frame(height: 2.0)
                    .background(
                        LinearGradient(colors: [Color.clear, Color("AccentColor")], startPoint: .trailing, endPoint: .leading)
                    )
                Text("\(context.state.vpnProtocol)")
                    .foregroundColor(Color.white)
                    .font(.caption)
                    .bold()
            }
        }
    }
}

