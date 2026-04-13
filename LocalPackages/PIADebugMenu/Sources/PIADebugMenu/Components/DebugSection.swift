import SwiftUI

/// On iOS renders as a `List` `Section`; on tvOS renders as a titled card for use in `ScrollView`.
@available(iOS 16, tvOS 17, *)
struct DebugSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        #if os(tvOS)
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .padding(.leading, 4)

                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
                .background(Color(white: 0.15), in: RoundedRectangle(cornerRadius: 12))
            }
        #else
            Section(title) {
                content()
            }
        #endif
    }
}
