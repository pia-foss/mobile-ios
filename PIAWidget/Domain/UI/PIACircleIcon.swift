
import SwiftUI

internal struct PIACircleIcon: View {
    
    internal let size: CGFloat
    internal let iconWidth: CGFloat
    
    init(size: CGFloat) {
        self.size = size
        self.iconWidth = (size / 2)
    }
    
    var body: some View {
        return ZStack {
            Circle()
                .fill(Color("BorderColor"))
                .frame(width: size)
            Image("ios-widget")
                .resizable()
                .frame(width: iconWidth, height: (iconWidth + 3))
                .padding()
        }
    }
}

