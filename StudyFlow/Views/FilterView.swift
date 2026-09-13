import SwiftUI
import SwiftData

struct FilterView: View {
    @Query(sort: \ClassSession.courseName)
    private var sessions: [ClassSession]

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                List {
                    ForEach(
                        Array(Set(sessions.map(\.courseName))).sorted(),
                        id: \.self
                    ) { course in

                        Label(
                            course,
                            systemImage: "checkmark.circle"
                        )
                    }
                }
            }
            .padding()
            .navigationTitle("Filter")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 350, height: 400)
    }
}
