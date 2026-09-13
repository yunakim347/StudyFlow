import SwiftUI
import SwiftData

struct ClassDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let session: ClassSession

    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.courseName)
                                .font(.system(size: 34, weight: .bold))

                            Text(weekdayName)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(session.colorName.swiftUIColor)
                            .frame(width: 24, height: 24)
                    }

                    Divider()

                    detailRow(
                        icon: "clock",
                        title: "Time",
                        value: "\(formattedTime(session.startTime)) – \(formattedTime(session.endTime))"
                    )

                    detailRow(
                        icon: "calendar",
                        title: "Day",
                        value: weekdayName
                    )
                    
                    detailRow(
                        icon: "calendar.badge.clock",
                        title: "Semester",
                        value: semesterRange
                    )

                    detailRow(
                        icon: "building.2",
                        title: "Venue",
                        value: session.venue.isEmpty
                            ? "No venue"
                            : session.venue
                    )

                    detailRow(
                        icon: "paintpalette",
                        title: "Color",
                        value: session.colorName.capitalized
                    )
                }
                .padding(28)
            }

            Divider()

            HStack {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }

                Spacer()

                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }

                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background(.regularMaterial)
        }
        .frame(width: 480, height: 460)
        .sheet(isPresented: $showingEditSheet) {
            EditClassView(session: session)
        }
        .alert(
            "Delete Class?",
            isPresented: $showingDeleteAlert
        ) {
            Button("Cancel", role: .cancel) {
            }

            Button("Delete", role: .destructive) {
                deleteClass()
            }
        } message: {
            Text(
                "Are you sure you want to delete \(session.courseName)? This action cannot be undone."
            )
        }
    }

    private func detailRow(
        icon: String,
        title: String,
        value: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(value)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var weekdayName: String {
        switch session.weekday {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "Unknown day"
        }
    }
    
    private var semesterRange: String {
        guard let start = session.semesterStart,
              let end = session.semesterEnd else {
            return "No semester dates"
        }

        return "\(formattedDate(start)) – \(formattedDate(end))"
    }

    private func formattedTime(_ date: Date) -> String {
        date.formatted(
            date: .omitted,
            time: .shortened
        )
    }
    private func formattedDate(_ date: Date) -> String {
        date.formatted(
            date: .abbreviated,
            time: .omitted
        )
    }

    private func deleteClass() {
        modelContext.delete(session)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to delete class: \(error)")
        }
    }
}

struct EditClassView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let session: ClassSession

    @State private var courseName: String
    @State private var weekday: Int
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var venue: String
    @State private var colorName: String
    @State private var semesterStart: Date
    @State private var semesterEnd: Date



    init(session: ClassSession) {
        self.session = session

        _courseName = State(initialValue: session.courseName)
        _weekday = State(initialValue: session.weekday)
        _startTime = State(initialValue: session.startTime)
        _endTime = State(initialValue: session.endTime)
        _venue = State(initialValue: session.venue)
        _colorName = State(initialValue: session.colorName)
        _semesterStart = State(
            initialValue: session.semesterStart
                ?? Calendar.current.startOfDay(for: Date())
        )

        _semesterEnd = State(
            initialValue: session.semesterEnd
                ?? Calendar.current.date(
                    byAdding: .month,
                    value: 4,
                    to: Calendar.current.startOfDay(for: Date())
                )
                ?? Date()
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Class")
                .font(.largeTitle)
                .fontWeight(.semibold)

            Form {
                TextField("Course name", text: $courseName)

                Picker("Day", selection: $weekday) {
                    ForEach(ClassOptions.weekdays, id: \.0) { value, name in
                        Text(name).tag(value)
                    }
                }

                DatePicker(
                    "Start time",
                    selection: $startTime,
                    displayedComponents: .hourAndMinute
                )

                DatePicker(
                    "End time",
                    selection: $endTime,
                    displayedComponents: .hourAndMinute
                )

                DatePicker(
                    "Semester start",
                    selection: $semesterStart,
                    displayedComponents: .date
                )

                DatePicker(
                    "Semester end",
                    selection: $semesterEnd,
                    in: semesterStart...,
                    displayedComponents: .date
                )

                TextField("Venue", text: $venue)

                Picker("Color", selection: $colorName) {
                    ForEach(ClassOptions.colors, id: \.self) { color in
                        HStack {
                            Circle()
                                .fill(color.swiftUIColor)
                                .frame(width: 12, height: 12)

                            Text(color.capitalized)
                        }
                        .tag(color)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    saveChanges()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canSave)
            }
        }
        .padding(24)
        .frame(width: 520, height: 620)
    }

    private var canSave: Bool {
        !courseName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
        && endTime > startTime
        && semesterEnd >= semesterStart
    }
    private func saveChanges() {
        session.courseName = courseName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        session.weekday = weekday
        session.startTime = startTime
        session.endTime = endTime

        session.venue = venue.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        session.colorName = colorName

        session.semesterStart = Calendar.current.startOfDay(
            for: semesterStart
        )

        session.semesterEnd = Calendar.current.startOfDay(
            for: semesterEnd
        )

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to update class: \(error)")
        }
    }
}

#Preview {
    ClassDetailView(
        session: ClassSession(
            courseName: "MATH1007",
            weekday: 3,
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            venue: "Room 101",
            colorName: "cyan"
        )
    )
    .modelContainer(for: ClassSession.self, inMemory: true)
}
