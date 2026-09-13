import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddTask = false
    
    @Query(sort: \StudyTask.dueDate)
    private var tasks: [StudyTask]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    showingAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
            .padding()

            Divider()

            if tasks.isEmpty {
                EmptySectionView(
                    title: "No Tasks",
                    message: "Add your assignments and deadlines here.",
                    icon: "checklist"
                )
            } else {
                List(tasks) { task in
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            task.isCompleted.toggle()
                        } label: {
                            Image(
                                systemName: task.isCompleted
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .font(.title3)
                        }
                        .buttonStyle(.plain)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(task.title)
                                .font(.headline)
                                .strikethrough(task.isCompleted)
                                .foregroundStyle(
                                    task.isCompleted
                                        ? .secondary
                                        : .primary
                                )

                            Text(task.courseName)
                                .foregroundStyle(.secondary)

                            Text(
                                task.dueDate.formatted(
                                    date: .abbreviated,
                                    time: .shortened
                                )
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    .contextMenu {
                        Button("Delete", role: .destructive) {
                            modelContext.delete(task)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}
