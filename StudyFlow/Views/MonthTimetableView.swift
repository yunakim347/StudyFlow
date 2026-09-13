import SwiftUI
import SwiftData

struct MonthTimetableView: View {
    @State private var selectedSession: ClassSession?

    @Query(sort: \ClassSession.startTime)
    private var sessions: [ClassSession]
    
    @Query(sort: \StudyTask.dueDate)
    private var tasks: [StudyTask]

    let referenceDate: Date
    let showWeekends: Bool

    private let calendar = Calendar.current

    private var columnCount: Int {
        showWeekends ? 7 : 5
    }

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(
                .flexible(),
                spacing: 0
            ),
            count: columnCount
        )
    }

    private var weekdayHeaders: [String] {
        if showWeekends {
            return [
                "Sun",
                "Mon",
                "Tue",
                "Wed",
                "Thu",
                "Fri",
                "Sat"
            ]
        }

        return [
            "Mon",
            "Tue",
            "Wed",
            "Thu",
            "Fri"
        ]
    }

    private var monthDates: [Date] {
        guard
            let monthInterval = calendar.dateInterval(
                of: .month,
                for: referenceDate
            ),
            let lastDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: monthInterval.end
            )
        else {
            return []
        }

        let firstDay = monthInterval.start

        let firstWeekday = calendar.component(
            .weekday,
            from: firstDay
        )

        let startOffset = -(firstWeekday - 1)

        let gridStart = calendar.date(
            byAdding: .day,
            value: startOffset,
            to: firstDay
        ) ?? firstDay

        let lastWeekday = calendar.component(
            .weekday,
            from: lastDay
        )

        let endOffset = 7 - lastWeekday

        let gridEnd = calendar.date(
            byAdding: .day,
            value: endOffset,
            to: lastDay
        ) ?? lastDay

        var dates: [Date] = []
        var currentDate = gridStart

        while currentDate <= gridEnd {
            if showWeekends || !isWeekend(currentDate) {
                dates.append(currentDate)
            }

            guard let nextDate = calendar.date(
                byAdding: .day,
                value: 1,
                to: currentDate
            ) else {
                break
            }

            currentDate = nextDate
        }

        return dates
    }

    var body: some View {
        VStack(spacing: 0) {
            monthHeader

            Divider()

            weekdayHeader

            Divider()

            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: 0
                ) {
                    ForEach(
                        monthDates,
                        id: \.self
                    ) { date in
                        monthCell(for: date)
                    }
                }
            }
        }
        .sheet(item: $selectedSession) { session in
            ClassDetailView(session: session)
        }
    }

    private var monthHeader: some View {
        HStack {
            Text(
                referenceDate.formatted(
                    .dateTime
                        .month(.wide)
                        .year()
                )
            )
            .font(.system(size: 26, weight: .semibold))

            Spacer()
        }
        .padding()
    }

    private var weekdayHeader: some View {
        LazyVGrid(
            columns: columns,
            spacing: 0
        ) {
            ForEach(
                weekdayHeaders,
                id: \.self
            ) { weekday in
                Text(weekday)
                    .fontWeight(.medium)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 42
                    )
            }
        }
    }

    private func monthCell(
        for date: Date
    ) -> some View {
        let sessionsForDate = sessions.filter {
            $0.occurs(on: date)
        }
        let tasksForDate = tasks.filter {
            calendar.isDate($0.dueDate, inSameDayAs: date)
        }

        return VStack(
            alignment: .leading,
            spacing: 6
        ) {
            HStack {
                Text(
                    date.formatted(
                        .dateTime.day()
                    )
                )
                .fontWeight(
                    calendar.isDateInToday(date)
                    ? .bold
                    : .regular
                )
                .foregroundStyle(
                    calendar.isDate(
                        date,
                        equalTo: referenceDate,
                        toGranularity: .month
                    )
                    ? Color.primary
                    : Color.secondary.opacity(0.55)
                )
                .frame(width: 26, height: 26)
                .background {
                    if calendar.isDateInToday(date) {
                        Circle()
                            .fill(
                                Color.accentColor.opacity(0.25)
                            )
                    }
                }

                Spacer()
            }

            ForEach(
                sessionsForDate.prefix(3)
            ) { session in
                Button {
                    selectedSession = session
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(
                                session.colorName.swiftUIColor
                            )
                            .frame(width: 7, height: 7)

                        Text(session.courseName)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .background(
                        session.colorName
                            .swiftUIColor
                            .opacity(0.18)
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 4
                        )
                    )
                }
                .buttonStyle(.plain)
            }
            ForEach(
                tasksForDate.prefix(2)
            ) { task in
                HStack(spacing: 5) {
                    Image(
                        systemName: task.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                    )
                    .font(.caption2)

                    Text(task.title)
                        .font(.caption)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted)

                    Spacer()
                }
                .foregroundStyle(
                    task.isCompleted
                        ? Color.secondary
                        : Color.primary
                )
                .padding(.horizontal, 5)
                .padding(.vertical, 3)
                .background(
                    Color.secondary.opacity(0.10)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 4
                    )
                )
            }

            if sessionsForDate.count > 3 {
                Text(
                    "+\(sessionsForDate.count - 3) more"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(7)
        .frame(
            maxWidth: .infinity,
            minHeight: 115,
            alignment: .topLeading
        )
        .background {
            if calendar.isDateInToday(date) {
                Color.accentColor.opacity(0.025)
            }
        }
        .overlay {
            Rectangle()
                .stroke(
                    Color.secondary.opacity(0.18),
                    lineWidth: 0.5
                )
        }
    }

    private func isWeekend(
        _ date: Date
    ) -> Bool {
        let weekday = calendar.component(
            .weekday,
            from: date
        )

        return weekday == 1 || weekday == 7
    }
}

#Preview {
    MonthTimetableView(
        referenceDate: Date(),
        showWeekends: true
    )
    .modelContainer(
        for: [
            ClassSession.self,
            StudyTask.self
        ],
        inMemory: true
    )
}
