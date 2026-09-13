import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var courseName = ""
    @State private var dueDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $title)

                TextField("Course name", text: $courseName)

                DatePicker(
                    "Due date",
                    selection: $dueDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
            .padding()
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(
                        title.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                    )
                }
            }
        }
        .frame(width: 420, height: 280)
    }

    private func saveTask() {
        let newTask = StudyTask(
            title: title.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            courseName: courseName.trimmingCharacters(
                in: .whitespacesAndNewlines
            ),
            dueDate: dueDate
        )

        modelContext.insert(newTask)
        dismiss()
    }
}
