import Foundation
import SwiftData

@Model
final class ClassSession {
    var courseName: String
    var weekday: Int
    var startTime: Date
    var endTime: Date
    var venue: String
    var colorName: String

    var semesterStart: Date?
    var semesterEnd: Date?

    init(
        courseName: String,
        weekday: Int,
        startTime: Date,
        endTime: Date,
        venue: String,
        colorName: String,
        semesterStart: Date? = nil,
        semesterEnd: Date? = nil
    ) {
        self.courseName = courseName
        self.weekday = weekday
        self.startTime = startTime
        self.endTime = endTime
        self.venue = venue
        self.colorName = colorName
        self.semesterStart = semesterStart
        self.semesterEnd = semesterEnd
    }
}
