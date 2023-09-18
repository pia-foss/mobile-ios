
import SwiftUI

internal struct PIACircleIndicator: View {

    internal let size: CGFloat
    internal let strokeWidth: CGFloat
    internal let color: Color

    @State private var outerCircle: CGFloat
    @State private var innerCircle: CGFloat
    @State private var iconSize: CGFloat

    init(size: CGFloat, strokeWidth: CGFloat, color: Color) {
        self.size = size
        self.strokeWidth = strokeWidth
        self.color = color
        self.outerCircle = size
        self.innerCircle = size - strokeWidth
        self.iconSize = size * 0.5
    }

    var body: some View {
        return ZStack {
            Circle()
                .strokeBorder(Color("BorderColor"),lineWidth: strokeWidth * 0.75)
                .frame(width: outerCircle, height: outerCircle)
                .background(Circle()
                    .strokeBorder(color, lineWidth: strokeWidth)
                    .frame(width: innerCircle, height: innerCircle)
                    .background(Image("vpn-button")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(color)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize, height: iconSize)
                    )
                )
        }
        .background(Color("WidgetBackground"))
        .cornerRadius(size / 2.0)
    }
}

