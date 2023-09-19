
import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 16.1, *)
struct PIAConnectionActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PIAConnectionAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            VStack {
                HStack(alignment: .bottom, spacing: 4) {
                    Image("ios-widget")
                        .resizable()
                        .frame(width: 16, height: 22)
                    Image("PIA-logo")
                        .resizable()
                        .frame(width: 30, height: 14)
                        .padding(.bottom, 1)
                }
                .padding(.bottom)
                PIAConnectionView(context: context, showProtocol: true)
                    .activityBackgroundTint(Color.black.opacity(0.85))
            }
            .padding()
            
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            DynamicIsland {
                // This content will be shown when user expands the island
                DynamicIslandExpandedRegion(.leading, priority: 300) {
                    PIACircleImageView(size: 46, image: context.state.regionFlag, contentMode: .fill)
                }
                
                DynamicIslandExpandedRegion(.trailing, priority: 200) {
                    Link(destination: URL(string: "piavpn:connect")!) {
                        PIACircleImageView(
                            size: 50,
                            image: context.state.connected ? "connected-button" : "disconnected-button"
                        )

                    }
                }
                
                DynamicIslandExpandedRegion(.center, priority: 100) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Region")
                                .font(.caption)
                                .foregroundColor(.white)
                            Text(context.state.regionName)
                                .font(.caption)
                                .foregroundColor(.white)
                                .bold()
                        }
                        
                    }
                    .frame(minWidth: (UIScreen.main.bounds.size.width * 0.55), alignment: .leading)
                    .dynamicIsland(verticalPlacement: .belowIfTooWide)

                }
                DynamicIslandExpandedRegion(.bottom) {
                    // Empty
                }
            } compactLeading: {
                // When the island is wider than the display cutout
                PIACircleIcon(size: 28.0)
            } compactTrailing: {
                // When the island is wider than the display cutout
                PIACircleImageView(
                    size: 24,
                    image: context.state.connected ? "green-checkmark" : "orange-cross"
                )
            } minimal: {
                // This is used when there are multiple activities
                PIACircleIcon(size: 28.0)
            }
            .contentMargins(.leading, 0, for: .compactLeading)
            
        }
    }
}

