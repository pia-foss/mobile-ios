
import WidgetKit
import SwiftUI
import PIALibrary
import PIALocalizations
import PIAAssetsWidget

@available(iOSApplicationExtension 16.1, *)
struct PIAConnectionActivityWidget: Widget {
    let localizedRegionText = L10n.Widget.LiveActivity.Region.title
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PIAConnectionAttributes.self) { context in
            // Create the view that appears on the Lock Screen and as a
            // banner on the Home Screen of devices that don't support the
            // Dynamic Island.
            VStack {
                HStack(alignment: .bottom, spacing: 4) {
                    Asset.iosWidget.swiftUIImage
                        .resizable()
                        .frame(width: 16, height: 22)
                    Asset.piaLogo.swiftUIImage
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
                    PIACircleImageView(size: 46, image: Image(context.state.regionFlag), contentMode: .fill)
                }
                
                DynamicIslandExpandedRegion(.trailing, priority: 200) {
                    Link(destination: URL(string: AppConstants.Widget.connect)!) {
                        PIACircleImageView(
                            size: 50,
                            image: context.state.connected ? Asset.connectedButton.swiftUIImage : Asset.disconnectedButton.swiftUIImage
                        )

                    }
                }
                
                DynamicIslandExpandedRegion(.center, priority: 100) {
                    VStack(alignment: .leading) {
                        Text(localizedRegionText)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.top, -8)
                        Text(context.state.regionName)
                            .font(.caption)
                            .foregroundColor(.white)
                            .bold()
                    }
                    .frame(minWidth: (UIScreen.main.bounds.size.width * 0.56), alignment: .leading)
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
                    image: context.state.connected ? Asset.greenCheckmark.swiftUIImage : Asset.disconnectedCross.swiftUIImage
                )
            } minimal: {
                // This is used when there are multiple activities
                PIACircleIcon(size: 28.0)
            }
            .contentMargins(.leading, 0, for: .compactLeading)
            
        }
    }
}

