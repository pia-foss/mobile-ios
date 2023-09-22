
import SwiftUI

internal struct PIACircleImageView: View {
    
    internal let size: CGFloat
    internal let image: String
    internal let contentMode: ContentMode
    
    
    init(size: CGFloat, image: String, contentMode: ContentMode = .fit) {
        self.size = size
        self.image = image
        self.contentMode = contentMode
    }
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}


