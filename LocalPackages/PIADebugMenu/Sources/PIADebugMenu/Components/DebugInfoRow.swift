import SwiftUI

struct DebugInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body)
                .foregroundStyle(.primary)
        }
        #if os(tvOS)
        .padding(.vertical, 8)
        #else
        .padding(.vertical, 2)
        #endif
    }
}
