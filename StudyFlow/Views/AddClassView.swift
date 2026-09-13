import SwiftUI
import SwiftData

struct AddClassView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var courseName = ""
    @State private var weekday = 2
    @State private var startTime = Self.makeTime(hour: 10)
    @State private var endTime = Self.makeTime(hour: 11)
    @State private var venue = ""
    @State private var colorName = "blue"
    @State private var semesterStart = Calendar.current.startOfDay(for: Date())

    @State private var semesterEnd =
        Calendar.current.date(
            byAdding: .month,
            value: 4,
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Date()



    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Class")
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
                    saveClass()
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

    private func saveClass() {
        let newClass = ClassSession(
            courseName: courseName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            weekday: weekday,
            startTime: startTime,
            endTime: endTime,
            venue: venue.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            colorName: colorName,
            semesterStart: semesterStart,
            semesterEnd: semesterEnd
        )

        modelContext.insert(newClass)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save class: \(error)")
        }
    }

    private static func makeTime(hour: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: 0,
            second: 0,
            of: Date()
        ) ?? Date()
    }
}

extension String {
    var swiftUIColor: Color {
        switch self {
        case "cyan":
            return .cyan
        case "green":
            return .green
        case "orange":
            return .orange
        case "pink":
            return .pink
        case "purple":
            return .purple
        case "red":
            return .red
        default:
            return .blue
        }
    }
}

#Preview {
    AddClassView()
        .modelContainer(for: ClassSession.self, inMemory: true)
}
