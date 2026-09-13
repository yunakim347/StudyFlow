import SwiftUI
import SwiftData

struct DayTimetableView: View {
    @State private var selectedSession: ClassSession?

    @Query(sort: \ClassSession.startTime)
    private var sessions: [ClassSession]

    let referenceDate: Date

    private let calendar = Calendar.current
    private let startingHour = 8
    private let endingHour = 18
    private let hourHeight: CGFloat = 90
    private let timeColumnWidth: CGFloat = 100

    private var timetableHeight: CGFloat {
        CGFloat(endingHour - startingHour) * hourHeight
    }

    private var sessionsForSelectedDay: [ClassSession] {
        sessions.filter {
            $0.occurs(on: referenceDate)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            dayHeader

            Divider()

            ScrollView(.vertical) {
                GeometryReader { geometry in
                    let availableWidth =
                        geometry.size.width - timeColumnWidth

                    HStack(
                        alignment: .top,
                        spacing: 0
                    ) {
                        timeColumn

                        scheduleColumn(
                            width: availableWidth
                        )
                    }
                }
                .frame(height: timetableHeight)
            }
        }
        .sheet(item: $selectedSession) { session in
            ClassDetailView(session: session)
        }
    }

    private var dayHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(
                    referenceDate.formatted(
                        .dateTime
                            .weekday(.wide)
                    )
                )
                .font(.system(size: 26, weight: .semibold))

                Text(
                    referenceDate.formatted(
                        .dateTime
                            .month(.wide)
                            .day()
                            .year()
                    )
                )
                .foregroundStyle(.secondary)
            }

            Spacer()

            if calendar.isDateInToday(referenceDate) {
                Text("Today")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private var timeColumn: some View {
        VStack(spacing: 0) {
            ForEach(
                startingHour..<endingHour,
                id: \.self
            ) { hour in
                Text(formattedHour(hour))
                    .foregroundStyle(.secondary)
                    .frame(
                        width: timeColumnWidth,
                        height: hourHeight,
                        alignment: .topLeading
                    )
                    .padding(.top, 8)
            }
        }
    }

    private func scheduleColumn(
        width: CGFloat
    ) -> some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                ForEach(
                    startingHour..<endingHour,
                    id: \.self
                ) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(
                            width: width,
                            height: hourHeight
                        )
                        .overlay {
                            Rectangle()
                                .stroke(
                                    Color.secondary.opacity(0.18),
                                    lineWidth: 0.5
                                )
                        }
                }
            }

            if calendar.isDateInToday(referenceDate) {
                Rectangle()
                    .fill(
                        Color.accentColor.opacity(0.035)
                    )
                    .frame(
                        width: width,
                        height: timetableHeight
                    )
            }

            ForEach(sessionsForSelectedDay) { session in
                Button {
                    selectedSession = session
                } label: {
                    ClassCard(session: session)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(
                    width: max(width - 20, 100),
                    height: classHeight(for: session)
                )
                .offset(
                    x: 10,
                    y: verticalOffset(for: session)
                )
                .zIndex(1)
            }
        }
        .frame(
            width: width,
            height: timetableHeight
        )
        .clipped()
    }

    private func verticalOffset(
        for session: ClassSession
    ) -> CGFloat {
        let hour = calendar.component(
            .hour,
            from: session.startTime
        )

        let minute = calendar.component(
            .minute,
            from: session.startTime
        )

        let minutesFromStart =
            ((hour - startingHour) * 60) + minute

        return max(
            0,
            CGFloat(minutesFromStart)
                / 60
                * hourHeight
        )
    }

    private func classHeight(
        for session: ClassSession
    ) -> CGFloat {
        let duration =
            session.endTime.timeIntervalSince(
                session.startTime
            )

        let minutes = max(
            duration / 60,
            20
        )

        return CGFloat(minutes / 60)
            * hourHeight
    }

    private func formattedHour(
        _ hour: Int
    ) -> String {
        let suffix = hour < 12 ? "am" : "pm"
        let displayHour =
            hour == 12 ? 12 : hour % 12

        return "\(displayHour):00 \(suffix)"
    }
}

#Preview {
    DayTimetableView(referenceDate: Date())
        .modelContainer(
            for: ClassSession.self,
            inMemory: true
        )
}
