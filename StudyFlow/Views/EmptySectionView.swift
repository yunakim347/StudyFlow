import SwiftUI

struct EmptySectionView: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)
                .fontWeight(.semibold)

            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }
}
