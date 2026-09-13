import SwiftUI
import SwiftData

@main
struct StudyFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                ClassSession.self,
                StudyTask.self
            ]
        )
    }
}
