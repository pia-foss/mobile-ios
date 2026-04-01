
import SwiftUI

internal struct PIACircleImageView: View {

    internal let size: CGFloat
    internal let image: Image
    internal let contentMode: ContentMode


    init(size: CGFloat, image: Image, contentMode: ContentMode = .fit) {
        self.size = size
        self.image = image
        self.contentMode = contentMode
    }

    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}


