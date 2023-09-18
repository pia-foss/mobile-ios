
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
                HStack {
                    PIACircleIcon(size: 25.0, strokeWidth: 1.0)
                    Text("Private Internet Access")
                        .foregroundColor(Color.white)
                        .font(.title3)
                }
                .padding(.bottom)
                PIAConnectionView(context: context)
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
                PIACircleIcon(size: 25.0, strokeWidth: 1.0)
            } compactTrailing: {
                // When the island is wider than the display cutout
                PIACircleIndicator(size: 25.0, strokeWidth: 1.0, color: Color("AccentColor"))
            } minimal: {
                // This is used when there are multiple activities
                PIACircleIcon(size: 25.0, strokeWidth: 1.0)
            }
        }
    }
}

