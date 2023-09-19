
import SwiftUI

internal struct PIACircleImageView: View {
    
    internal let size: CGFloat
    internal let image: String
    
    
    init(size: CGFloat, image: String) {
        self.size = size
        self.image = image
        
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}


