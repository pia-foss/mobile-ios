
import SwiftUI

internal struct PIACircleIcon: View {

    internal let size: CGFloat
    internal let strokeWidth: CGFloat

    init(size: CGFloat, strokeWidth: CGFloat) {
        self.size = size
        self.strokeWidth = strokeWidth
    }

    var body: some View {
        return ZStack {
            Circle()
                .strokeBorder(Color("BorderColor"), lineWidth: strokeWidth)
                .frame(width: size, height: size)
                .background(Image("ios-widget")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(
                        EdgeInsets(
                            top: size * 0.15,
                            leading: 0.0,
                            bottom: 0.0,
                            trailing: 0.0
                        )
                    )
                    .frame(
                        width: size,
                        height: size,
                        alignment: Alignment(horizontal: .center, vertical: .top)
                    )
                )
        }
        .background(Color("WidgetBackground"))
        .cornerRadius(size / 2.0)
    }
}

