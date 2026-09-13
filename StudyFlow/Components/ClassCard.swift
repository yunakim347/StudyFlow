import SwiftUI

struct ClassCard: View {
    let session: ClassSession

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 5
        ) {
            Text(session.courseName)
                .fontWeight(.semibold)
                .lineLimit(1)

            Text(timeRangeText)
                .font(.caption)
                .foregroundStyle(.primary.opacity(0.85))

            if !session.venue.isEmpty {
                Text(session.venue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(
            session.colorName
                .swiftUIColor
                .opacity(0.35)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(session.colorName.swiftUIColor)
                .frame(width: 4)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 5)
        )
    }

    private var timeRangeText: String {
        let start = session.startTime.formatted(
            date: .omitted,
            time: .shortened
        )

        let end = session.endTime.formatted(
            date: .omitted,
            time: .shortened
        )

        return "\(start) – \(end)"
    }
}
