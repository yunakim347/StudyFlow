import Foundation
import SwiftData

@Model
final class StudyTask {
    var title: String
    var courseName: String
    var dueDate: Date
    var isCompleted: Bool

    init(
        title: String,
        courseName: String,
        dueDate: Date,
        isCompleted: Bool = false
    ) {
        self.title = title
        self.courseName = courseName
        self.dueDate = dueDate
        self.isCompleted = isCompleted
    }
}
