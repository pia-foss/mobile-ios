
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
                }
                .padding(.bottom)
                PIAConnectionView(context: context, showProtocol: true)
            }
            .padding()
            
        } dynamicIsland: { context in
            // Create the views that appear in the Dynamic Island.
            DynamicIsland {
                // This content will be shown when user expands the island
                DynamicIslandExpandedRegion(.leading) {
                    // Empty
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    // Empty
                }
                
                DynamicIslandExpandedRegion(.center) {
                    // Empty
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    PIAConnectionView(context: context)
                }
            } compactLeading: {
                // When the island is wider than the display cutout
                PIACircleIcon(size: 28.0)
            } compactTrailing: {
                // When the island is wider than the display cutout
                PIACircleImageView(size: 24.0, image: "green-checkmark")
            } minimal: {
                // This is used when there are multiple activities
                PIACircleIcon(size: 30.0)
            }
        }
    }
}

