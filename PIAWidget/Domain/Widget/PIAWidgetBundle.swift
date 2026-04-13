import SwiftUI
import WidgetKit

@main
struct PIAWidgetBundle: WidgetBundle {
    var body: some Widget {
        PIAWidget()

        if #available(iOS 16.1, *) {
            PIAConnectionActivityWidget()
        }
    }
}
