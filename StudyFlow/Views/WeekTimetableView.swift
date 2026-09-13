import SwiftUI
import SwiftData

struct WeekTimetableView: View {
    @State private var selectedSession: ClassSession?
    @State private var showingFilter = false

    @Query(sort: \ClassSession.startTime)
    private var sessions: [ClassSession]

    let referenceDate: Date
    let showWeekends: Bool

    private let calendar = Calendar.current
    private let startingHour = 8
    private let endingHour = 18
    private let hourHeight: CGFloat = 90
    private let timeColumnWidth: CGFloat = 100

    private var timetableHeight: CGFloat {
        CGFloat(endingHour - startingHour) * hourHeight
    }

    private var sundayStart: Date {
        let startOfReferenceDay =
            calendar.startOfDay(for: referenceDate)

        let weekday = calendar.component(
            .weekday,
            from: startOfReferenceDay
        )

        return calendar.date(
            byAdding: .day,
            value: -(weekday - 1),
            to: startOfReferenceDay
        ) ?? startOfReferenceDay
    }

    private var allWeekDates: [Date] {
        (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset,
                to: sundayStart
            )
        }
    }

    private var visibleDates: [Date] {
        if showWeekends {
            return allWeekDates
        }

        return allWeekDates.filter { date in
            let weekday = calendar.component(
                .weekday,
                from: date
            )

            return weekday != 1 && weekday != 7
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            dayHeader
            Divider()

            ScrollView(.vertical) {
                GeometryReader { geometry in
                    let availableWidth =
                        geometry.size.width - timeColumnWidth

                    let dayWidth =
                        availableWidth
                        / CGFloat(visibleDates.count)

                    HStack(
                        alignment: .top,
                        spacing: 0
                    ) {
                        timeColumn

                        ForEach(
                            visibleDates,
                            id: \.self
                        ) { date in
                            dayColumn(
                                date: date,
                                width: dayWidth
                            )
                        }
                    }
                }
                .frame(height: timetableHeight)
            }
        }
        .sheet(item: $selectedSession) { session in
            ClassDetailView(session: session)
        }
        .sheet(isPresented: $showingFilter) {
            FilterView()
        }
    }

    private var header: some View {
        HStack {
            Text(weekRangeText)
                .font(
                    .system(
                        size: 26,
                        weight: .semibold
                    )
                )

            Spacer()

            Button {
                showingFilter = true
            } label: {
                Label(
                    "Filter",
                    systemImage:
                        "line.3.horizontal.decrease"
                )
            }
        }
        .padding()
    }

    private var dayHeader: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: timeColumnWidth)

            ForEach(
                visibleDates,
                id: \.self
            ) { date in
                VStack(spacing: 5) {
                    Text(shortWeekday(for: date))
                        .fontWeight(.medium)

                    Text(dayNumber(for: date))
                        .font(.caption)
                        .foregroundStyle(
                            isToday(date)
                            ? Color.white
                            : Color.secondary
                        )
                        .frame(width: 26, height: 26)
                        .background {
                            if isToday(date) {
                                Circle()
                                    .fill(Color.accentColor)
                            }
                        }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 58)
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

    private func dayColumn(
        date: Date,
        width: CGFloat
    ) -> some View {
        return ZStack(alignment: .topLeading) {
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
                                    Color.secondary
                                        .opacity(0.18),
                                    lineWidth: 0.5
                                )
                        }
                }
            }

            if isToday(date) {
                Rectangle()
                    .fill(
                        Color.accentColor.opacity(0.035)
                    )
                    .frame(
                        width: width,
                        height: timetableHeight
                    )
            }

            ForEach(
                sessions.filter {
                    $0.occurs(on: date)
                }
            ) { session in
                Button {
                    selectedSession = session
                } label: {
                    ClassCard(session: session)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(
                    width: max(width - 10, 60),
                    height: classHeight(
                        for: session
                    )
                )
                .offset(
                    x: 5,
                    y: verticalOffset(
                        for: session
                    )
                )
                .zIndex(1)
                .help(
                    "View \(session.courseName)"
                )
            }
        }
        .frame(
            width: width,
            height: timetableHeight
        )
        .clipped()
    }

    private var weekRangeText: String {
        guard let endDate = calendar.date(
            byAdding: .day,
            value: 6,
            to: sundayStart
        ) else {
            return ""
        }

        let sameMonth = calendar.isDate(
            sundayStart,
            equalTo: endDate,
            toGranularity: .month
        )

        let sameYear = calendar.isDate(
            sundayStart,
            equalTo: endDate,
            toGranularity: .year
        )

        if sameMonth {
            let month =
                sundayStart.formatted(
                    .dateTime.month(.wide)
                )

            let startDay =
                sundayStart.formatted(
                    .dateTime.day()
                )

            let endDay =
                endDate.formatted(
                    .dateTime.day()
                )

            return "\(month) \(startDay) – \(endDay)"
        }

        if sameYear {
            let start =
                sundayStart.formatted(
                    .dateTime
                        .month(.abbreviated)
                        .day()
                )

            let end =
                endDate.formatted(
                    .dateTime
                        .month(.abbreviated)
                        .day()
                )

            return "\(start) – \(end)"
        }

        let start =
            sundayStart.formatted(
                .dateTime
                    .month(.abbreviated)
                    .day()
                    .year()
            )

        let end =
            endDate.formatted(
                .dateTime
                    .month(.abbreviated)
                    .day()
                    .year()
            )

        return "\(start) – \(end)"
    }

    private func shortWeekday(
        for date: Date
    ) -> String {
        date.formatted(
            .dateTime.weekday(.abbreviated)
        )
    }

    private func dayNumber(
        for date: Date
    ) -> String {
        date.formatted(
            .dateTime.day()
        )
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
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
            ((hour - startingHour) * 60)
            + minute

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
        let suffix =
            hour < 12 ? "am" : "pm"

        let displayHour =
            hour == 12 ? 12 : hour % 12

        return "\(displayHour):00 \(suffix)"
    }
}
